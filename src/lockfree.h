// Icaro for upgrade, updates in code. based on tfs 1.4 
// Special Credits: Pota, Ruby
// Copyright 2023 The Forgotten Server Authors. All rights reserved.
// Use of this source code is governed by the GPL-2.0 License that can be found in the LICENSE file.

#ifndef FS_LOCKFREE_H_8C707AEB7C7235A2FBC5D4EDDF03B008
#define FS_LOCKFREE_H_8C707AEB7C7235A2FBC5D4EDDF03B008

#if _MSC_FULL_VER >= 190023918 // Workaround for VS2015 Update 2. Boost.Lockfree is a header-only library, so this should be safe to do.
#define _ENABLE_ATOMIC_ALIGNMENT_FIX
#endif

#include <boost/lockfree/stack.hpp>
#include <memory>

/*
 * we use this to avoid instantiating multiple free lists for objects of the
 * same size and it can be replaced by a variable template in C++14
 *
 * template <std::size_t TSize, size_t CAPACITY>
 * boost::lockfree::stack<void*, boost::lockfree::capacity<CAPACITY>> lockfreeFreeList;
 */
template <std::size_t TSize, size_t CAPACITY>
struct LockfreeFreeList
{
	using FreeList = boost::lockfree::stack<void*, boost::lockfree::capacity<CAPACITY>>;
	static FreeList& get()
	{
		static FreeList freeList;
		return freeList;
	}
};

template <typename T, size_t CAPACITY>
class LockfreePoolingAllocator
{
public:
	using value_type = T;

	LockfreePoolingAllocator() = default;

	template <typename U>
	constexpr LockfreePoolingAllocator(const LockfreePoolingAllocator<U, CAPACITY>&) noexcept {}

	T* allocate(size_t) const {
		auto& inst = LockfreeFreeList<sizeof(T), CAPACITY>::get();
		void* p;
		if (!inst.pop(p)) {
			p = operator new (sizeof(T));
		}
		return static_cast<T*>(p);
	}

	void deallocate(T* p, size_t) const {
		auto& inst = LockfreeFreeList<sizeof(T), CAPACITY>::get();
		if (!inst.bounded_push(p)) {
			operator delete(p);
		}
	}

	template <typename U>
	struct rebind {
		using other = LockfreePoolingAllocator<U, CAPACITY>;
	};
};

#endif