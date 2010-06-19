/*
 * Process Hacker - 
 *   internal object manager
 * 
 * Copyright (C) 2009 wj32
 * 
 * This file is part of Process Hacker.
 * 
 * Process Hacker is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Process Hacker is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Process Hacker.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifndef REFP_H
#define REFP_H

/**
 * Gets a pointer to the object header for an object.
 *
 * \param Object A pointer to an object.
 *
 * \return A pointer to the object header of the object.
 */
#define PhObjectToObjectHeader(Object) ((PPH_OBJECT_HEADER)CONTAINING_RECORD((PCHAR)(Object), PH_OBJECT_HEADER, Body))

/**
 * Gets a pointer to an object from an object header.
 *
 * \param ObjectHeader A pointer to an object header.
 *
 * \return A pointer to an object.
 */
#define PhObjectHeaderToObject(ObjectHeader) ((PVOID)&((PPH_OBJECT_HEADER)(ObjectHeader))->Body)

/**
 * Calculates the total size to allocate for an object.
 *
 * \param Size The size of the object to allocate.
 *
 * \return The new size, including space for the object header.
 */
#define PhpAddObjectHeaderSize(Size) ((Size) + FIELD_OFFSET(PH_OBJECT_HEADER, Body))

#define PhpGetObjectSecurityDescriptor(Object, ObjectType) \
    ((PSECURITY_DESCRIPTOR *)PTR_ADD_OFFSET((Object), (ObjectType)->OffsetOfSecurityDescriptor))

typedef struct _PH_OBJECT_HEADER *PPH_OBJECT_HEADER;
typedef struct _PH_OBJECT_TYPE *PPH_OBJECT_TYPE;

/** Reserved. */
#define PHOBJ_LOCK_BIT 0x1
/** The object was allocated from the small free list. */
#define PHOBJ_FROM_SMALL_FREE_LIST 0x2
/** The object was allocated from the type free list. */
#define PHOBJ_FROM_TYPE_FREE_LIST 0x4

/**
 * The object header contains object manager information 
 * including the reference count of an object and its 
 * type.
 */
typedef struct _PH_OBJECT_HEADER
{
    /** The reference count of the object. */
    LONG RefCount;

    /** Internal flags. */
    ULONG Flags;

    union
    {
        /** The size of the object, excluding the header. */
        SIZE_T Size;
        /** A pointer to the object header of the next object to free. */
        PPH_OBJECT_HEADER NextToFree;
    };

    /** The type of the object. */
    PPH_OBJECT_TYPE Type;

#ifdef DEBUG
    PVOID StackBackTrace[16];
    LIST_ENTRY ObjectListEntry;
#endif

#ifdef _M_IX86
    // There are 4 + 4 + 4 + 4 = 16 bytes before Body.
    QUAD Body;
#else
    // There are 4 + 4 + 8 + 8 = 24 bytes before Body.
    // 16 byte alignment requires Body to be at 32 bytes, 
    // so the inclusion of AllocationBase does not waste 
    // any space.
    PVOID AllocationBase;
    OCTO Body;
#endif
} PH_OBJECT_HEADER, *PPH_OBJECT_HEADER;

#ifndef DEBUG
#ifdef _M_IX86
C_ASSERT(FIELD_OFFSET(PH_OBJECT_HEADER, RefCount) == 0x0);
C_ASSERT(FIELD_OFFSET(PH_OBJECT_HEADER, Flags) == 0x4);
C_ASSERT(FIELD_OFFSET(PH_OBJECT_HEADER, NextToFree) == 0x8);
C_ASSERT(FIELD_OFFSET(PH_OBJECT_HEADER, Type) == 0xc);
C_ASSERT(FIELD_OFFSET(PH_OBJECT_HEADER, Body) == 0x10);
#else
C_ASSERT(FIELD_OFFSET(PH_OBJECT_HEADER, RefCount) == 0x0);
C_ASSERT(FIELD_OFFSET(PH_OBJECT_HEADER, Flags) == 0x4);
C_ASSERT(FIELD_OFFSET(PH_OBJECT_HEADER, NextToFree) == 0x8);
C_ASSERT(FIELD_OFFSET(PH_OBJECT_HEADER, Type) == 0x10);
C_ASSERT(FIELD_OFFSET(PH_OBJECT_HEADER, AllocationBase) == 0x18);
C_ASSERT(FIELD_OFFSET(PH_OBJECT_HEADER, Body) == 0x20);
#endif
#endif

/**
 * An object type specifies a kind of object and 
 * its delete procedure.
 */
typedef struct _PH_OBJECT_TYPE
{
    /** The flags that were used to create the object type. */
    ULONG Flags;
    /** The number of bytes at which the pointer to the 
     * object's security descriptor is stored. */
    UCHAR OffsetOfSecurityDescriptor;
    UCHAR Reserved1;
    UCHAR Reserved2;
    UCHAR Reserved3;
    /** An optional procedure called when objects of this type are freed. */
    PPH_TYPE_DELETE_PROCEDURE DeleteProcedure;
    /** The name of the type. */
    PWSTR Name;
    /** The total number of objects of this type that are alive. */
    ULONG NumberOfObjects;
    /** A free list to use when allocating for this type. */
    PH_FREE_LIST FreeList;

    GENERIC_MAPPING GenericMapping;
} PH_OBJECT_TYPE, *PPH_OBJECT_TYPE;

/**
 * Increments a reference count, but will never increment 
 * from 0 to 1.
 *
 * \param RefCount A pointer to a reference count.
 */
FORCEINLINE BOOLEAN PhpInterlockedIncrementSafe(
    __inout PLONG RefCount
    )
{
    LONG refCount;

    /* Here we will attempt to increment the reference count, 
     * making sure that it is not 0.
     */

    while (TRUE)
    {
        refCount = *RefCount;

        /* Check if the reference count is 0. If it is, the 
         * object is being or about to be deleted.
         */
        if (refCount == 0)
            return FALSE;

        /* Try to increment the reference count. */
        if (_InterlockedCompareExchange(
            RefCount,
            refCount + 1,
            refCount
            ) == refCount)
        {
            /* Success. */
            return TRUE;
        }

        /* Someone else changed the reference count before we did. 
         * Go back and try again.
         */
    }
}

PPH_OBJECT_HEADER PhpAllocateObject(
    __in PPH_OBJECT_TYPE ObjectType,
    __in SIZE_T ObjectSize,
    __in ULONG Flags
    );

VOID PhpFreeObject(
    __in PPH_OBJECT_HEADER ObjectHeader
    );

VOID PhpDeferDeleteObject(
    __in PPH_OBJECT_HEADER ObjectHeader
    );

NTSTATUS PhpDeferDeleteObjectRoutine(
    __in PVOID Parameter
    );

#endif
