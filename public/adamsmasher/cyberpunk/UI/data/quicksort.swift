
public abstract class QuicksortTemplate extends IScriptable {

  public final static func Sort(items: script_ref<array<Variant>>, comparator: ref<SortComparatorTemplate>, leftIndex: Int32, rightIndex: Int32) -> Void {
    let index: Int32;
    if ArraySize(Deref(items)) > 1 {
      index = QuicksortTemplate.Partition(items, comparator, leftIndex, rightIndex);
      if leftIndex < index - 1 {
        QuicksortTemplate.Sort(items, comparator, leftIndex, index - 1);
      };
      if index < rightIndex {
        QuicksortTemplate.Sort(items, comparator, index, rightIndex);
      };
    };
  }

  private final static func Partition(items: script_ref<array<Variant>>, comparator: ref<SortComparatorTemplate>, leftIndex: Int32, rightIndex: Int32) -> Int32 {
    let tempItem: Variant;
    let i: Int32 = leftIndex;
    let j: Int32 = rightIndex;
    let pivot: Variant = Deref(items)[FloorF(Cast(rightIndex) + Cast(leftIndex) / 2.00)];
    while i <= j {
      while comparator.Compare(Deref(items)[i], pivot) {
        i += 1;
      };
      while !comparator.Compare(Deref(items)[j], pivot) {
        j -= 1;
      };
      if i <= j {
        tempItem = Deref(items)[i];
        Deref(items)[i] = Deref(items)[j];
        Deref(items)[j] = tempItem;
        i += 1;
        j -= 1;
      };
    };
    return i;
  }
}

public abstract class SortComparatorTemplate extends IScriptable {

  public func Compare(left: Variant, right: Variant) -> Bool {
    return false;
  }
}

public class QuicksortInt extends IScriptable {

  public final static func Sort(items: script_ref<array<Int32>>, comparator: ref<IntComparator>, leftIndex: Int32, rightIndex: Int32) -> Void {
    let index: Int32;
    if ArraySize(Deref(items)) > 1 {
      index = QuicksortInt.Partition(items, comparator, leftIndex, rightIndex);
      if leftIndex < index - 1 {
        QuicksortInt.Sort(items, comparator, leftIndex, index - 1);
      };
      if index < rightIndex {
        QuicksortInt.Sort(items, comparator, index, rightIndex);
      };
    };
  }

  private final static func Partition(items: script_ref<array<Int32>>, comparator: ref<IntComparator>, leftIndex: Int32, rightIndex: Int32) -> Int32 {
    let tempItem: Int32;
    let i: Int32 = leftIndex;
    let j: Int32 = rightIndex;
    let pivot: Int32 = Deref(items)[FloorF((Cast(rightIndex) + Cast(leftIndex)) / 2.00)];
    while i <= j {
      while comparator.Compare(Deref(items)[i], pivot) > 0 {
        i += 1;
      };
      while comparator.Compare(Deref(items)[j], pivot) < 0 {
        j -= 1;
      };
      if i <= j {
        tempItem = Deref(items)[i];
        Deref(items)[i] = Deref(items)[j];
        Deref(items)[j] = tempItem;
        i += 1;
        j -= 1;
      };
    };
    return i;
  }
}

public class IntComparator extends IScriptable {

  public func Compare(left: Int32, right: Int32) -> Int32 {
    if left == right {
      return 0;
    };
    return left < right ? 1 : -1;
  }
}

public class QuicksortInventoryItemData extends IScriptable {

  public final static func Sort(items: script_ref<array<InventoryItemData>>, comparator: ref<InventoryItemDataComparator>, leftIndex: Int32, rightIndex: Int32) -> Void {
    let index: Int32;
    if ArraySize(Deref(items)) > 1 {
      index = QuicksortInventoryItemData.Partition(items, comparator, leftIndex, rightIndex);
      if leftIndex < index - 1 {
        QuicksortInventoryItemData.Sort(items, comparator, leftIndex, index - 1);
      };
      if index < rightIndex {
        QuicksortInventoryItemData.Sort(items, comparator, index, rightIndex);
      };
    };
  }

  private final static func Partition(items: script_ref<array<InventoryItemData>>, comparator: ref<InventoryItemDataComparator>, leftIndex: Int32, rightIndex: Int32) -> Int32 {
    let tempItem: InventoryItemData;
    let i: Int32 = leftIndex;
    let j: Int32 = rightIndex;
    let pivot: InventoryItemData = Deref(items)[FloorF((Cast(rightIndex) + Cast(leftIndex)) / 2.00)];
    while i <= j {
      while comparator.Compare(Deref(items)[i], pivot) > 0 {
        i += 1;
      };
      while comparator.Compare(Deref(items)[j], pivot) < 0 {
        j -= 1;
      };
      if i <= j {
        tempItem = Deref(items)[i];
        Deref(items)[i] = Deref(items)[j];
        Deref(items)[j] = tempItem;
        i += 1;
        j -= 1;
      };
    };
    return i;
  }
}

public class InventoryItemDataComparator extends IScriptable {

  public func Compare(left: InventoryItemData, right: InventoryItemData) -> Int32 {
    return 0;
  }
}
