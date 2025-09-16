import { styleTags, tags as t } from "@lezer/highlight";

export const rHighlight = styleTags({
  "repeat while for if else return break next in": t.controlKeyword,
  "Logical!": t.bool,
  function: t.definitionKeyword,
  "FunctionCall/Identifier FunctionCall/String": t.function(t.variableName),
  "NamedArg!": t.function(t.attributeName),
  Comment: t.lineComment,
  "Numeric Integer Complex Inf": t.number,
  "SpecialConstant!": t.literal,
  String: t.string,
  "ArithOp MatrixOp": t.arithmeticOperator,
  BitOp: t.bitwiseOperator,
  CompareOp: t.compareOperator,
  "ExtractionOp NamespaceOp": t.operator,
  AssignmentOperator: t.definitionOperator,
  "...": t.punctuation,
  "( )": t.paren,
  "[ ]": t.squareBracket,
  "{ }": t.brace,
  $: t.derefOperator,
  ", ;": t.separator,
});
