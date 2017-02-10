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
import core.ast.symbol;
import core.ast.type;

/// This is the abstract base class for all expression nodes.
abstract class Expression : AstNode
{
    private enum nodeType = NodeType.expression;

    Type type;

    this(Type type)
    {
        this.type = type;
    }
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
    this(Type type, Expression left, Expression right)
    {
        super(type);
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
    this(Type type, Expression left, Expression right)
    {
        super(type, left, right);
    }

    /// ditto
    static AddExp opCall(Type type, Expression left, Expression right)
    {
        return new AddExp(type, left, right);
    }
}

final class ArrayLiteralExpression : Expression
{
    private enum nodeType = NodeType.arrayLiteralExpression;

    Expression[] elements;

    this(Type type, Expression[] elements)
    {
        super(type);
        this.elements = elements;
    }

    static ArrayLiteralExpression opCall(Type type, Expression[] elements)
    {
        return new ArrayLiteralExpression(type, elements);
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
    this(Type type, Expression left, Expression right)
    {
        super(type, left, right);
    }

    /// ditto
    static AssignExpression opCall(Type type, Expression left, Expression right)
    {
        return new AssignExpression(type, left, right);
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
    this(Type type, Expression left, Expression right)
    {
        super(type, left, right);
    }

    /// ditto
    static BlitExpression opCall(Type type, Expression left, Expression right)
    {
        return new BlitExpression(type, left, right);
    }
}

class CallExpression : UnaryExpression
{
    private enum nodeType = NodeType.callExpression;

    FunctionDeclaration functionDeclaration;
    Expression[] arguments;

    this(Type type, Expression expression, FunctionDeclaration functionDeclaration, Expression[] arguments = [])
    {
        super(type, expression);
        this.functionDeclaration = functionDeclaration;
        this.arguments = arguments;
    }

    static CallExpression opCall(Type type, Expression expression, FunctionDeclaration functionDeclaration, Expression[] arguments = [])
    {
        return new CallExpression(type, expression, functionDeclaration, arguments);
    }
}

final class DeclarationExpression : Expression
{
    private enum nodeType = NodeType.declarationExpression;

    Declaration declaration;

    this(Type type, Declaration declaration)
    {
        super(type);
        this.declaration = declaration;
    }

    static DeclarationExpression opCall(Type type, Declaration declaration)
    {
        return new DeclarationExpression(type, declaration);
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
    this(Type type, int value)
    {
        super(type);
        this.value = value;
    }

    /// ditto
    static IntegerExp opCall(Type type, int value)
    {
        return new IntegerExp(type, value);
    }
}

class UnaryExpression : Expression
{
    private enum nodeType = NodeType.unaryExpression;

    Expression expression;

    this(Type type, Expression expression)
    {
        super(type);
        this.expression = expression;
    }

    static UnaryExpression opCall(Type type, Expression expression)
    {
        return new UnaryExpression(type, expression);
    }
}

class SymbolExpression : Expression
{
    private enum nodeType = NodeType.symbolExpression;

    Declaration variable;

    this(Type type, Declaration variable)
    {
        super(type);
        this.variable = variable;
    }

    static SymbolExpression opCall(Type type, Declaration variable)
    {
        return new SymbolExpression(type, variable);
    }
}

final class VariableExpression : SymbolExpression
{
    private enum nodeType = NodeType.variableExpression;

    this(Type type, Declaration variable)
    {
        super(type, variable);
    }

    static VariableExpression opCall(Type type, Declaration variable)
    {
        return new VariableExpression(type, variable);
    }
}

final class StringExpression : Expression
{
    private enum nodeType = NodeType.stringExpression;

    string value;

    this(Type type, string value)
    {
        super(type);
        this.value = value;
    }

    static StringExpression opCall(Type type, string value)
    {
        return new StringExpression(type, value);
    }
}

final class FunctionExpression : Expression
{
    private enum nodeType = NodeType.functionExpression;

    FunctionLiteralDeclaration declaration;
    NodeType functionType;

    this(Type type, FunctionLiteralDeclaration declaration)
    {
        // if (declaration is null)
        //     throw new Exception("The given FunctionLiteralDeclaration is null");

        super(type);
        this.declaration = declaration;
        functionType = declaration.functionType;
    }

    static FunctionExpression opCall(Type type, FunctionLiteralDeclaration declaration)
    {
        return new FunctionExpression(type, declaration);
    }
}
