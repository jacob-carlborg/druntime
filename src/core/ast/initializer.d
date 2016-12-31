/**
 * Initializer AST nodes.
 *
 * Copyright: Copyright Jacob Carlborg 2016.
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Authors:   Jacob Carlborg
 * Source:    $(DRUNTIMESRC core/ast/_initializer.d)
 */
module core.ast.initializer;

import core.ast.ast_node;
import core.ast.expression;

/// This class is the abstract base class of all initializer nodes.
abstract class Initializer : AstNode
{
    private enum nodeType = NodeType.initializer;
}

final class ExpressionInitializer : Initializer
{
    private enum nodeType = NodeType.expressionInitializer;

    Expression expression;

    this(Expression expression)
    {
        this.expression = expression;
    }

    static ExpressionInitializer opCall(Expression expression)
    {
        return new ExpressionInitializer(expression);
    }
}
