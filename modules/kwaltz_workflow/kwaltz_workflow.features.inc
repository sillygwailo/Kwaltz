<?php

/**
 * Implementation of hook_workflow_defaults().
 */
function kwaltz_workflow_workflow_defaults() {
  module_load_include('inc', 'kwaltz_workflow', 'kwaltz_workflow.features.workflow');
  $args = func_get_args();
  return call_user_func_array('_kwaltz_workflow_workflow_defaults', $args);
}
