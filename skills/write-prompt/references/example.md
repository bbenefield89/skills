# Example

A user asks for a prompt to find every caller of a deprecated API in a large repository.
The dispatch selects Subagent with `Explore`, because the search reads many files and the parent needs only the list.
`suggest-model` returns Research · Light with Haiku 5.5, medium. The dispatch uses `model: haiku` and `effort: medium`.
The task prompt names the API, the directories to search, and the directories to ignore.
Its output format asks for a table of file path, line, and call form. It tells the agent to run one real search check, because the model is Haiku 5.5.
The response has no run section, because the mode is Subagent.
