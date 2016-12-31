/**
 * Declaration AST nodes.
 *
 * Copyright: Copyright Jacob Carlborg 2016.
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Authors:   Jacob Carlborg
 * Source:    $(DRUNTIMESRC core/_attribute.d)
 */
module core.ast.declaration;

import core.ast.ast_node;
import core.ast.initializer;
import core.ast.statement;
import core.ast.symbol;
import core.ast.type;

/// This is the abstract base class for all declaration nodes.
abstract class Declaration : Symbol
{
    private enum nodeType = NodeType.declaration;

    /// The type of the declaration, if any, otherwise `null`.
    Type type;

    /**
     * Initializes this declaration with the given values.
     *
     * Params:
     *  ident = the identifier of the declaration
     *  type = the type of the declaration
     */
    this(Identifier ident, Type type = null)
    {
        super(ident);
        this.type = type;
    }
}

/**
 * This class represents a variable declaration, with or without initializer.
 *
 * ---
 * int foo; // variable declaration without initializer
 * int bar = 3; // variable declaration with initializer
 * ---
 */
class VarDeclaration : Declaration
{
    private enum nodeType = NodeType.varDeclaration;

    /// The initializer of the variable declaration, if any, otherwise `null`.
    Initializer initializer;

    /**
     * Creates a new variable declaration with the given values.
     *
     * Params:
     *  ident = the identifier of the variable declaration
     *  type = the type of the variable declaration
     *  initializer = the initializer of the variable declaration, if any
     */
    this(Identifier ident, Type type, Initializer initializer = null)
    {
        super(ident, type);
        this.initializer = initializer;
    }

    /// ditto
    static VarDeclaration opCall(Identifier ident, Type type, Initializer initializer = null)
    {
        return new VarDeclaration(ident, type, initializer);
    }
}

class FunctionDeclaration : Declaration
{
    private enum nodeType = NodeType.functionDeclaration;

    Statement body_;

    this(Identifier ident, Type type, Statement body_ = null)
    {
        super(ident, type);
        this.body_ = body_;
    }

    static FunctionDeclaration opCall(Identifier ident, Type type, Statement body_ = null)
    {
        return new FunctionDeclaration(ident, type, body_);
    }
}
