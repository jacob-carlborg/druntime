/**
 * Declaration AST nodes.
 *
 * Copyright: Copyright Jacob Carlborg 2016.
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Authors:   Jacob Carlborg
 * Source:    $(DRUNTIMESRC core/ast/_statement.d)
 */
module core.ast.statement;

import core.ast.ast_node;
import core.ast.expression;
import core.ast.symbol;
import core.ast.type;

abstract class Statement : AstNode
{
    private enum nodeType = NodeType.statement;
}

class ExpressionStatement : Statement
{
    private enum nodeType = NodeType.expressionStatement;

    Expression expression;

    this(Expression expression)
    {
        this.expression = expression;
    }

    static ExpressionStatement opCall(Expression expression)
    {
        return new ExpressionStatement(expression);
    }
}

class CompoundStatement : Statement
{
    private enum nodeType = NodeType.compoundStatement;

    Statement[] statements;

    this(Statement[] statements)
    {
        this.statements = statements;
    }

    static CompoundStatement opCall(Statement[] statements)
    {
        return new CompoundStatement(statements);
    }
}

class ForeachStatement : Statement
{
    private enum nodeType = NodeType.foreachStatement;

    NodeType foreachType;
    Parameter[] parameters;
    Expression aggr;
    Statement body_;

    this(NodeType foreachType, Parameter[] parameters, Expression aggr, Statement body_)
    {
        this.foreachType = foreachType;
        this.parameters = parameters;
        this.aggr = aggr;
        this.body_ = body_;
    }
}

class ImportStatement : Statement
{
    private enum nodeType = NodeType.importStatement;

    Symbol[] imports;

    this(Symbol[] imports)
    {
        this.imports = imports;
    }

    static ImportStatement opCall(Symbol[] imports)
    {
        return new ImportStatement(imports);
    }
}
