<?php

/**
 * Helper to implementation of hook_workflow_defaults().
 */
function _kwaltz_workflow_workflow_defaults() {
 $defaults = array();
  $defaults[] = array(
    'name' => 'Moderation',
    'machine_name' => 'moderation',
    'tab_roles' => array(
      '0' => NULL,
    ),
    'options' => NULL,
    'states' => array(
      '1' => array(
        'ref' => '1',
        'module' => 'kwaltz_workflow',
        'state' => '(creation)',
        'weight' => '-50',
        'sysid' => '1',
        'status' => '1',
      ),
      '2' => array(
        'ref' => '2',
        'module' => 'kwaltz_workflow',
        'state' => 'Draft',
        'weight' => '-10',
        'sysid' => '0',
        'status' => '1',
      ),
      '3' => array(
        'ref' => '3',
        'module' => 'kwaltz_workflow',
        'state' => 'In Moderation',
        'weight' => '-2',
        'sysid' => '0',
        'status' => '1',
      ),
      '4' => array(
        'ref' => '4',
        'module' => 'kwaltz_workflow',
        'state' => 'Is Moderated',
        'weight' => '2',
        'sysid' => '0',
        'status' => '1',
      ),
      '5' => array(
        'ref' => '5',
        'module' => 'kwaltz_workflow',
        'state' => 'Live',
        'weight' => '10',
        'sysid' => '0',
        'status' => '1',
      ),
    ),
    'roles' => array(
      'author' => array(
        'name' => 'author',
        'transitions' => array(
          '0' => array(
            'from' => '1',
            'to' => '2',
          ),
        ),
      ),
    ),
  );
  return $defaults;

}
