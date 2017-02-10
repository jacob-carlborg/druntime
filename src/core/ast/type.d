/**
 * Type AST nodes.
 *
 * Copyright: Copyright Jacob Carlborg 2016.
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Authors:   Jacob Carlborg
 * Source:    $(DRUNTIMESRC core/_attribute.d)
 */
module core.ast.type;

import core.ast.ast_node;
import core.ast.declaration;
import core.ast.expression;
import core.ast.util;
import core.ast.symbol;

/**
 * This enum represents a type kind/tag which all types contain.
 *
 * For basic types, which all use the same class for the AST node,
 * the type kind is used identify the actual type.
 */
enum TypeKind
{
    // This order needs to match the one in the compiler

    /// Array/slice, `T[]`
    array,

    /// Static array, `T[dimension]`
    staticArray,

    /// Associative array, `T[type]`
    associativeArray,

    /// Pointer, `T*`
    pointer,

    /// Reference, `ref T`
    reference,

    /// Function, `void function()`
    function_,

    /// Identifier, `a`
    identifier,

    /// Class, `class C {}`
    class_,

    /// Struct, `struct S {}`
    struct_,

    /// Enum, `enum E {}`
    enum_,



    /// Delegate, `void delegate()`
    delegate_,

    /// No type
    none,

    /// Void, `void`
    void_,

    /// 8 bit signed integer, `byte`
    int8,

    /// 8 bit unsigned integer, `ubyte`
    uint8,

    /// 16 bit signed integer, `short`
    int16,

    /// 16 bit unsigned integer, `ushort`
    uint16,

    /// 32 bit signed integer, `int`
    int32,

    /// 32 bit unsigned integer, `uint`
    uint32,

    /// 64 bit signed integer, `long`
    int64,


    /// 64 bit unsigned integer, `ulong`
    uint64,

    /// 32 bit floating point, `float`
    float32,

    /// 64 bit floating point, `double`
    float64,

    /**
     * The largest native floating point provided by the hardware
     * (80 bit on x86), `real`.
     */
    float80,

    /// 32 bit imaginary floating point, `ifloat`
    imaginary32,

    /// 64 bit imaginary floating point, `idouble`
    imaginary64,

    /**
     * The largest native floating point provided by the hardware
     * (80 bit on x86) as imaginary, `real`.
     */
    imaginary80,

    /// 32 bit complex floating point, `cfloat`
    complex32,

    /// 64 bit compelx floating point, `cfloat`
    complex64,

    /**
     * The largest native floating point provided by the hardware
     * (80 bit on x86) as complex, `real`.
     */
    complex80,



    /// Boolean, `bool`
    bool_,

    /// UTF-8 code point, `char`
    char_,

    /// UTF-16 code point, `wchar`
    wchar_,

    /// UTF-32 code point, `dchar`
    dchar_,

    /// Error type
    error,

    /// Instance type
    instance,

    /// Typeof type
    typeof_,

    /// Tuple type
    tuple,

    /// Slice type
    slice,

    /// Return type
    return_,



    /// Null literal, `null`
    null_,

    /// Vector, `__vector(T[dimension]])`
    vector,

    /// 128 bit signed integer (reserved for future use), `cent`
    int128,

    /// 128 bit unsigned integer (reserved for future use), `ucent`
    uint128,
}

/// This is the abstract base class for all type nodes.
abstract class Type : AstNode
{
    private enum nodeType = NodeType.type;

    /// The type kind/tag of the type
    TypeKind typeKind;

    string deco;

    /**
     * Initializes this instance with the given type kind.
     *
     * Params:
     *  typeKind = the type kind of the type
     */
    this(TypeKind typeKind, string deco)
    {
        this.typeKind = typeKind;
        this.deco = deco;
    }

    /**
     * Creates a new AST node which represents the given type.
     *
     * Params:
     *  T = the type which the AST node should represent
     *
     * Returns: the newly created AST node
     */
    static Type opCall(T)()
    {
        static if (is(T == int))
            return BasicType(TypeKind.int32);
        else
            static assert(false, "Type() not implement for type '" ~ T.stringof ~ "'");
    }
}

/**
 * This class represents the basic types in the AST.
 *
 * The same class is used to represent all the basic types and the type kind is
 * used to differentiate the types.
 *
 * The basic types include:
 * * void
 * * bool
 * * byte
 * * ubyte
 * * short
 * * ushort
 * * int
 * * uint
 * * long
 * * ulong
 * * cent (reserved for future use)
 * * ucent (reserved for future use)
 * * float
 * * double
 * * real
 * * ifloat
 * * idouble
 * * ireal
 * * cfloat
 * * cdouble
 * * creal
 * * char
 * * wchar
 * * dchar
 */
final class BasicType : Type
{
    private enum nodeType = NodeType.basicType;

    /**
     * Creates a new basic type from the given type kind.
     *
     * Params:
     *  typeKind = the type kind indicates the actual type
     */
    this(TypeKind typeKind, string deco)
    {
        super(typeKind, deco);
    }

    /// ditto
    static BasicType opCall(TypeKind kind, string deco)
    {
        return new BasicType(kind, deco);
    }
}

abstract class NextType : Type
{
    private enum nodeType = NodeType.nextType;

    Type next;

    this(TypeKind typeKind, string deco, Type next)
    {
        super(typeKind, deco);
        this.next = next;
    }
}

class ArrayType : NextType
{
    private enum nodeType = NodeType.arrayType;

    this(TypeKind typeKind, string deco, Type next)
    {
        super(typeKind, deco, next);
    }
}

class PointerType : NextType
{
    private enum nodeType = NodeType.pointerType;

    this(string deco, Type type)
    {
        super(TypeKind.pointer, deco, type);
    }

    static PointerType opCall(string deco, Type type)
    {
        return new PointerType(deco, type);
    }
}

final class EnumType : Type
{
    private enum nodeType = NodeType.enumType;

    EnumDeclaration declaration;

    this(string deco, EnumDeclaration declaration)
    {
        super(TypeKind.enum_, deco);
        this.declaration = declaration;
    }

    static EnumType opCall(string deco, EnumDeclaration declaration)
    {
        return new EnumType(deco, declaration);
    }
}

final class FunctionType : NextType
{
    private enum nodeType = NodeType.functionType;

    Parameter[] parameters;
    VariadicType variadicType;
    Linkage linkage;

    this(string deco, Parameter[] parameters, Type returnType,
        VariadicType variadicType = VariadicType.nonVariadic,
        Linkage linkage = Linkage.d)
    {
        super(TypeKind.function_, deco, returnType);
        this.parameters = parameters;
        this.variadicType = variadicType ;
        this.linkage = linkage;
    }

    /// ditto
    static FunctionType opCall(string deco, Parameter[] parameters, Type returnType,
        VariadicType variadicType = VariadicType.nonVariadic,
        Linkage linkage = Linkage.d)
    {
        return new FunctionType(deco, parameters, returnType, variadicType, linkage);
    }
}

final class TupleType : Type
{
    private enum nodeType = NodeType.tupleType;

    Parameter[] arguments;

    this(string deco, Parameter[] arguments)
    {
        super(TypeKind.tuple, deco);
        this.arguments = arguments;
    }
}

final class Parameter : AstNode
{
    private enum nodeType = NodeType.parameter;

    StorageClass storageClass;
    Type type;
    Identifier identifier;
    Expression defaultArgument;

    this(StorageClass storageClass, Type type, Identifier identifier,
        Expression defaultArgument = null)
    {
        this.storageClass = storageClass;
        this.type = type;
        this.identifier = identifier;
        this.defaultArgument = defaultArgument;
    }

    static Parameter opCall(StorageClass storageClass, Type type,
        Identifier identifier, Expression defaultArgument = null)
    {
        return new Parameter(storageClass, type, identifier, defaultArgument);
    }
}
