[
  (if_statement)
  (while_statement)
  (for_statement)
  (case_statement)
  (function_definition)
  (subshell)
  (process_substitution)
  (command_substitution)
  (compound_statement)
  (case_item)
  (pipeline)
  (string)
  (raw_string)
] @indent.begin

[
  "done"
  "fi"
  "esac"
  "}"
  ")"
] @indent.end

[
  "done"
  "fi"
  "esac"
  "}"
  ")"
  "else"
  "elif"
  (elif_clause)
  ";;"
] @indent.branch
