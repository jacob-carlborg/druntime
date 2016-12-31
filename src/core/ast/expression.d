/**
 * Expression AST nodes.
 *
 * Copyright: Copyright Jacob Carlborg 2016.
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Authors:   Jacob Carlborg
 * Source:    $(DRUNTIMESRC core/_attribute.d)
 */
module core.ast.expression;

import core.ast.ast_node;
import core.ast.declaration;

/// This is the abstract base class for all expression nodes.
abstract class Expression : AstNode
{
    private enum nodeType = NodeType.expression;
}

/**
 * This is the abstract base class for all binary expression nodes.
 *
 * ---
 * 1 + 2
 * a - b
 * ---
 */
abstract class BinExp : Expression
{
    private enum nodeType = NodeType.binExp;

    /// The left hand side expression
    Expression left;

    /// The right hand side expression
    Expression right;

    /**
     * Initializes this instance with given left and right hand expressions.
     *
     * Params:
     *  left = the left hand side expression
     *  right = the right hand side expression
     */
    this(Expression left, Expression right)
    {
        this.left = left;
        this.right = right;
    }
}

/**
 * This class represents an add expression.
 *
 * ---
 * 1 + 2
 * a + b
 * ---
 */
final class AddExp : BinExp
{
    private enum nodeType = NodeType.addExp;

    /**
     * Creates a new add expression with given left and right hand expressions.
     *
     * Params:
     *  left = the left hand side expression
     *  right = the right hand side expression
     */
    this(Expression left, Expression right)
    {
        super(left, right);
    }

    /// ditto
    static AddExp opCall(Expression left, Expression right)
    {
        return new AddExp(left, right);
    }
}

class AssignExpression : BinExp
{
    private enum nodeType = NodeType.assignExpression;

    /**
     * Creates a new assign expression with given left and right hand expressions.
     *
     * Params:
     *  left = the left hand side expression
     *  right = the right hand side expression
     */
    this(Expression left, Expression right)
    {
        super(left, right);
    }

    /// ditto
    static AssignExpression opCall(Expression left, Expression right)
    {
        return new AssignExpression(left, right);
    }
}

final class BlitExpression : AssignExpression
{
    private enum nodeType = NodeType.blitExpression;

    /**
     * Creates a new blit expression with given left and right hand expressions.
     *
     * Params:
     *  left = the left hand side expression
     *  right = the right hand side expression
     */
    this(Expression left, Expression right)
    {
        super(left, right);
    }

    /// ditto
    static BlitExpression opCall(Expression left, Expression right)
    {
        return new BlitExpression(left, right);
    }
}

final class DeclarationExpression : Expression
{
    private enum nodeType = NodeType.declarationExpression;

    Declaration declaration;

    this(Declaration declaration)
    {
        this.declaration = declaration;
    }

    static DeclarationExpression opCall(Declaration declaration)
    {
        return new DeclarationExpression(declaration);
    }
}

/**
 * This class represents an integer expression/literal.
 *
 * ---
 * 1
 * 2
 * ---
 */
final class IntegerExp : Expression
{
    private enum nodeType = NodeType.integerExp;

    /// The value of the integer expression.
    int value;

    /**
     * Creates a new integer expression with given integer value.
     *
     * Params:
     *  value = the value of the integer expression
     */
    this(int value)
    {
        this.value = value;
    }

    /// ditto
    static IntegerExp opCall(int value)
    {
        return new IntegerExp(value);
    }
}

class SymbolExpression : Expression
{
    private enum nodeType = NodeType.symbolExpression;

    Declaration variable;

    this(Declaration variable)
    {
        this.variable = variable;
    }

    static SymbolExpression opCall(Declaration variable)
    {
        return new SymbolExpression(variable);
    }
}

final class VariableExpression : SymbolExpression
{
    private enum nodeType = NodeType.variableExpression;

    this(Declaration variable)
    {
        super(variable);
    }

    static VariableExpression opCall(Declaration variable)
    {
        return new VariableExpression(variable);
    }
}
