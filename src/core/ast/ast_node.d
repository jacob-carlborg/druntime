/**
 * The root node of the AST.
 *
 * Copyright: Copyright Jacob Carlborg 2016.
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Authors:   Jacob Carlborg
 * Source:    $(DRUNTIMESRC core/ast/_ast_node.d)
 */
module core.ast.ast_node;

enum NodeType : short
{
    reserved,

    astNode,

    declaration,
    enumDeclaration,
    varDeclaration,
    functionDeclaration,
    functionLiteralDeclaration,

    expression,
    arrayLiteralExpression,
    assignExpression,
    addExp,
    binExp,
    blitExpression,
    callExpression,
    declarationExpression,
    delegateExpression,
    functionExpression,
    integerExp,
    stringExpression,
    symbolExpression,
    unaryExpression,
    variableExpression,

    initializer,
    expressionInitializer,

    symbol,
    scopeSymbol,

    statement,
    compoundStatement,
    expressionStatement,
    foreachStatement,
    importStatement,

    type,
    arrayType,
    basicType,
    enumType,
    functionType,
    nextType,
    pointerType,
    tupleType,

    parameter
}

/// This class is the root class for all AST nodes.
abstract class AstNode
{
    private enum nodeType = NodeType.astNode;
}

macro ast(AstNode node)
{
    return node;
}

// macro T ast(T: AstNode)(T node)
// {
//     return node;
// }
