/**
 * Symbol AST nodes.
 *
 * Copyright: Copyright Jacob Carlborg 2016.
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Authors:   Jacob Carlborg
 * Source:    $(DRUNTIMESRC core/ast/_symbol.d)
 */
module core.ast.symbol;

import core.ast.ast_node;

alias Identifier = string;

/**
 * This class represents a symbol in the AST.
 *
 * It's the base class of all AST nodes which are a symbols, like declarations.
 */
class Symbol : AstNode
{
    private enum nodeType = NodeType.symbol;

    /// The identifier of the symbol.
    Identifier ident;

    /**
     * Creates a new symbol with the given identifier.
     *
     * Params:
     *  ident = the identifier of the symbol
     */
    this(Identifier ident = null)
    {
        this.ident = ident;
    }

    /// ditto
    static Symbol opCall(Identifier ident = null)
    {
        return new Symbol(ident);
    }
}
