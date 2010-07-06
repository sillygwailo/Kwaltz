<?php
// $Id$

/**
 * Return an array of the modules to be enabled when this profile is installed.
 *
 * @return
 *   An array of modules to enable.
 */
function kwaltz_profile_modules() {
  $default = array('color', 'comment', 'help', 'menu', 'taxonomy', 'dblog');
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
      'type' => 'page',
      'name' => st('Page'),
      'module' => 'node',
      'description' => st("A <em>page</em>, similar in form to a <em>story</em>, is a simple method for creating and displaying information that rarely changes, such as an \"About us\" section of a website. By default, a <em>page</em> entry does not allow visitor comments and is not featured on the site's initial home page."),
      'custom' => TRUE,
      'modified' => TRUE,
      'locked' => FALSE,
      'help' => '',
      'min_word_count' => '',
    ),
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
  variable_set('node_options_page', array('status'));
  variable_set('comment_page', COMMENT_NODE_DISABLED);

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
  install_add_permissions(3, $author_permissions);
  install_add_permissions(4, $moderator_permissions);
  install_add_permissions(5, $publisher_permissions);

  // Workflow requires a permissions rebuild. Otherwise Drupal
  // complains, and manual intervention is necessary.
  if (node_access_needs_rebuild()) {
    node_access_rebuild();
  }

  // Build the workflow so that it shows up initially in 
  // admin/build/workflow without having to visit 
  // admin/build/features
  features_rebuild();

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
