/**
 * Linkage.
 *
 * Copyright: Copyright Jacob Carlborg 2017.
 * License:   $(LINK2 http://www.boost.org/LICENSE_1_0.txt, Boost License 1.0)
 * Authors:   Jacob Carlborg
 * Source:    $(DRUNTIMESRC core/ast/_linkage.d)
 */
module core.ast.util;

/// This enum represents a linkage.
enum Linkage
{
    /// The default linkage.
    default_,

    /// D linkage.
    d,

    /// C linkage-
    c,

    /// C++ linkage.
    cpp,

    /// C++ linkage.
    windows,

    /// Pascal linkage.
    pascal,

    /// Objective-C linkage.
    objectiveC,
}

/// This type represents a storage class.
alias StorageClass = ulong;

enum VariadicType : byte
{
    nonVariadic,
    untyped,
    typed
}
