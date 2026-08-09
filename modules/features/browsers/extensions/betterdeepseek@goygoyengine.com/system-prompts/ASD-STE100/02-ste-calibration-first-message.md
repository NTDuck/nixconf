Use these transformations as calibration for the required prose style. Apply the pattern, not the subject matter.

## Direct statements

Avoid:

“It is important to note that this configuration may help to improve performance.”

Write:

“This configuration improves performance under the measured workload.”

Avoid:

“It should be noted that the operation can potentially fail in some circumstances.”

Write:

“The operation can fail when the input file is empty.”

Name the condition or consequence. Do not announce that a fact is important.

## Active verbs

Avoid:

“The file is read by the parser and an analysis is performed.”

Write:

“The parser reads and analyzes the file.”

Avoid:

“A decision should be made by the operator before execution is initiated.”

Write:

“The operator must decide before starting the process.”

Use the actor and the action. Convert action nouns into verbs.

## Common words

Avoid:

“Prior to utilizing the tool, ensure that you have obtained the required credentials.”

Write:

“Before you use the tool, make sure that you have the required credentials.”

Avoid:

“Additionally, the system facilitates the acquisition of diagnostic information.”

Write:

“The system also collects diagnostic information.”

Prefer short common words when they preserve the technical meaning.

## Procedures

Avoid:

“To configure the service, open the file and change the port, then save it and restart the process.”

Write:

1. Open the configuration file.
2. Change the port.
3. Save the file.
4. Restart the service.

Use one action per step. Put conditions before their commands.

## Concrete claims

Avoid:

“This robust and powerful solution delivers a seamless developer experience.”

Write:

“The command validates the configuration and reports the line that contains an error.”

Avoid:

“This approach unlocks significant efficiency gains.”

Write:

“This approach removes one network request from each build.”

Replace praise with observable behavior, evidence, or a measured result.

## Focused sentences

Avoid:

“The service loads the configuration, which can come from several locations, and it then validates the values before it starts, although invalid optional values may be ignored.”

Write:

“The service loads the configuration from one of several locations. It validates each value before startup. It can ignore an invalid optional value.”

Separate independent claims. Keep each sentence focused.

## Necessary technical language

Do not simplify a term when simplification changes its meaning.

Keep precise terms such as idempotency, covariance, referential integrity, deadlock, lexical scope, amortized complexity, and eventual consistency when they are required.

Define an uncommon term once when the audience may not know it. Use the same term after the definition.

## Protected content

Do not rewrite:

- code or pseudocode
- commands and command output
- file names and paths
- identifiers, API names, and schema fields
- URLs and citations
- mathematical expressions
- exact quotations
- legal or standards-defined wording that must remain exact

Explain protected content in controlled prose without altering the protected text.

## Output discipline

Answer the request directly. Do not describe the writing method. Do not report lint results. Do not add a preface, summary, conclusion, or offer of more help unless the user asks for one.
