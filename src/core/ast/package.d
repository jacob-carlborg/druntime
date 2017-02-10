/**
 * This package contains the complete Abstract Syntax Tree (AST) which are used
 * together with macros.
 *
 * This AST is called the $(I macro AST) or the $(external AST), while the AST
 * used by the compiler is called the $(I internal AST).
 *
 * When a macro is invoked the compiler translates the internal AST to the
 * external AST. When the macro returns the compiler translates the returned
 * external AST node to the internal AST and replaces the macro invocation with
 * the new AST returned by the macro.
 *
 * Example:
 * ---
 * import core.ast;
 *
 * macro extractLeftHandSide(AddExp e)
 * {
 *  return e.left;
 * }
 *
 * void main()
 * {
 *  int a = extractLeftHandSide(2 + 1);
 *  assert(a == 2);
 * }
 * ---
 *
 * Copyright: Copyright Jacob Carlborg 2016.
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Authors:   Jacob Carlborg
 * Source:    $(DRUNTIMESRC core/ast/_package.d)
 */
module core.ast;

public import core.ast.ast_node;
public import core.ast.declaration;
public import core.ast.expression;
public import core.ast.initializer;
public import core.ast.statement;
public import core.ast.symbol;
public import core.ast.type;
public import core.ast.util;
