<?php
// $Id$

/**
 * Return an array of the modules to be enabled when this profile is installed.
 *
 * @return
 *   An array of modules to enable.
 */
function kwaltz_profile_modules() {
  $default = array('help', 'menu', 'taxonomy', 'dblog');
  $contrib = array(
    'module_grants', 'module_grants_monitor', 'node_tools',
    'user_tools', 'profile', 'trigger', 'smart_tabs', 'diff', 'features',
    'revisioning', 'token', 'token_actions', 'workflow', 'workflow_access', 
    'install_profile_api', 'kwaltz_workflow',
  );
  return array_merge($default, $contrib);
}

/**
 * Return a description of the profile for the initial installation screen.
 *
 * @return
 *   An array with keys 'name' and 'description' describing this profile,
 *   and optional 'language' to override the language selection for
 *   language-specific profiles.
 */
function kwaltz_profile_details() {
  return array(
    'name' => 'Kwaltz',
    'description' => 'A simple multi-step workflow. Based on the instructions at http://jamestombs.co.uk/2010-07-05/displaying-nodes-as-blocks-using-block-api/1252 .'
  );
}

/**
 * Return a list of tasks that this profile supports.
 *
 * @return
 *   A keyed array of tasks the profile will perform during
 *   the final stage. The keys of the array will be used internally,
 *   while the values will be displayed to the user in the installer
 *   task list.
 */
function kwaltz_profile_task_list() {
}

/**
 * Perform any final installation tasks for this profile.
 *
 * @param $task
 *   The current $task of the install system. When hook_profile_tasks()
 *   is first called, this is 'profile'.
 * @param $url
 *   Complete URL to be used for a link or form action on a custom page,
 *   if providing any, to allow the user to proceed with the installation.
 *
 * @return
 *   An optional HTML string to display to the user. Only used if you
 *   modify the $task, otherwise discarded.
 */
function kwaltz_profile_tasks(&$task, $url) {

  // Insert default user-defined node types into the database. For a complete
  // list of available node type attributes, refer to the node type API
  // documentation at: http://api.drupal.org/api/HEAD/function/hook_node_info.
  $types = array(
    array(
      'type' => 'story',
      'name' => st('Story'),
      'module' => 'node',
      'description' => st("A <em>story</em>, similar in form to a <em>page</em>, is ideal for creating and displaying content that informs or engages website visitors. Press releases, site announcements, and informal blog-like entries may all be created with a <em>story</em> entry. By default, a <em>story</em> entry is automatically featured on the site's initial home page, and provides the ability to post comments."),
      'custom' => TRUE,
      'modified' => TRUE,
      'locked' => FALSE,
      'help' => '',
      'min_word_count' => '',
    ),
  );

  foreach ($types as $type) {
    $type = (object) _node_type_set_defaults($type);
    node_type_save($type);
  }

  // Default page to not be promoted and have comments disabled.
  variable_set('node_options_story', array('promote', 'revision', 'revision_moderation'));

  // Don't display date and author information for page nodes by default.
  $theme_settings = variable_get('theme_settings', array());
  $theme_settings['toggle_node_info_page'] = FALSE;
  variable_set('theme_settings', $theme_settings);

  // http://jamestombs.co.uk/2010-06-30/create-a-multi-step-moderation-process-in-drupal-6/1189
  // Role names are slightly different to keep them distinct from the
  // terminology used in the Workflow module. "Author role", for example,
  // is renamed "Writer". They must proceed in this order, since the
  // required Features module assigns workflows to the numeric role ID.

  install_include(kwaltz_profile_modules());
  install_add_role('Writer');
  install_add_role('Moderator');
  install_add_role('Publisher');

  $moderator_permissions = array(
    'access All tab',
    'access I Can Edit tab',
    'access I Can View tab',
    'edit any story content',
    'revert revisions',
    'view revisions',
    'access Pending tab',
    'edit revisions',
    'view revision status messages',
  );

  $author_permissions = array(
    'create story content',
    'edit own story content',
    'view revision status messages',
    'view revisions of own story content',
  );

  $publisher_permissions = array(
    'access Published tab',
    'access Unpublished tab',
    'publish revisions',
    'unpublish current revision',
  );

  // Publisher permissions are a superset of Moderator's permissions
  $publisher_permissions = array_merge($moderator_permissions, $publisher_permissions);
 
  // Role IDs are hard-coded and matched up with the IDs in the features module

  $author_rid = install_get_rid('Writer');
  $moderator_rid = install_get_rid('Moderator');
  $publisher_rid = install_get_rid('Publisher');

  install_add_permissions($author_rid, $author_permissions);
  install_add_permissions($moderator_rid, $moderator_permissions);
  install_add_permissions($publisher_rid, $publisher_permissions);

  // Workflow requires a permissions rebuild. Otherwise Drupal
  // complains, and manual intervention is necessary.
  if (node_access_needs_rebuild()) {
    node_access_rebuild();
  }

  // Build the workflow so that it shows up initially in 
  // admin/build/workflow without having to visit 
  // admin/build/features
  features_rebuild();

  // We know the workflow we'll need has the machine name 'moderation',
  // since that's what we use in the kwaltz_workflow features module.
  $moderation_workflow = install_workflow_get_wid('moderation');
  $workflow_types = array();
  $workflow_types['story'] = array(
    'workflow' => $moderation_workflow,
    'placement' => array(
      'node' => TRUE, 
      'comment' => FALSE
    ),
  );
  workflow_types_save($workflow_types);

  // store some state IDs. We'll use them latter too.
  $draft = install_workflow_get_sid('Draft', 'kwaltz_workflow');
  $in_moderation = install_workflow_get_sid('In Moderation', 'kwaltz_workflow');
  $is_moderated = install_workflow_get_sid('Is Moderated', 'kwaltz_workflow');
  $live = install_workflow_get_sid('Live', 'kwaltz_workflow');

  $original_state = $is_moderated;
  $transition_state = $live;
  $transition_id = install_workflow_get_transition_id($original_state, $transition_state);

  if ($transition_id) {

    // Thanks to http://drupal.org/node/822468 sample code to programmatically
    // assign actions.
    //
    // The Trigger module automatically adds a 'save post' action on a 'publish' action.
    module_load_include('inc', 'trigger', 'trigger.admin');
    foreach (actions_actions_map(actions_get_all_actions()) as $aid => $action) {
      if ($action['callback'] == 'node_publish_action') {
        $form_values['aid'] = $aid;
        $form_values['hook'] = 'workflow';
        $form_values['operation'] = 'workflow-story-' . $transition_id;;
        trigger_assign_form_submit(array(), array('values' => $form_values));
      }
    }

  }

  // build Workflow access control

  $access = array();

  $draft = install_workflow_get_sid('Draft', 'kwaltz_workflow');
  $in_moderation = install_workflow_get_sid('In Moderation', 'kwaltz_workflow');
  $is_moderated = install_workflow_get_sid('Is Moderated', 'kwaltz_workflow');
  $live = install_workflow_get_sid('Live', 'kwaltz_workflow');

  $moderation_workflow_states = array_keys(workflow_get_states($moderation_workflow));

  $rids = array_keys(user_roles(FALSE));

  // default permissions are unchecked
  $zeros = array();
  foreach ($rids as $rid) {
    $zeroes[$rid] = 0;
  }
  
  foreach ($moderation_workflow_states as $moderation_workflow_state) {
    $access[$moderation_workflow_state] = array(
      'view' => $zeroes,
      'update' => $zeroes,
      'delete' => $zeroes,
    );
  }

  // override default access control permissions
  $access[$draft]['view'][$publisher_rid] = $publisher_rid;
  $access[$in_moderation]['update'][$moderator_rid] = $moderator_rid;
  $access[$is_moderated]['update'][$publisher_rid] = $publisher_rid;

  // save the permissions
  workflow_access_form_submit(array(), array('values' => array('workflow_access' => $access)));

  // Update the menu router information.
  menu_rebuild();
}

/**
 * Implementation of hook_form_alter().
 *
 * Allows the profile to alter the site-configuration form. This is
 * called through custom invocation, so $form_state is not populated.
 */
function kwaltz_form_alter(&$form, $form_state, $form_id) {
  if ($form_id == 'install_configure') {
    // Set default for site name field.
    $form['site_information']['site_name']['#default_value'] = $_SERVER['SERVER_NAME'];
  }
}
