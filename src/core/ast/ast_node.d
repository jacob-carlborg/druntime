/**
 * The root node of the AST.
 *
 * Copyright: Copyright Jacob Carlborg 2016.
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Authors:   Jacob Carlborg
 * Source:    $(DRUNTIMESRC core/ast/_ast_node.d)
 */
module core.ast.ast_node;

package enum NodeType : short
{
    astNode,

    declaration,
    varDeclaration,
    functionDeclaration,

    expression,
    assignExpression,
    addExp,
    binExp,
    blitExpression,
    declarationExpression,
    integerExp,
    symbolExpression,
    variableExpression,

    initializer,
    expressionInitializer,

    symbol,

    statement,
    compoundStatement,

    type,
    basicType
}

/// This class is the root class for all AST nodes.
abstract class AstNode
{
    private enum nodeType = NodeType.astNode;
}
