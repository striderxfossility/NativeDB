
public native class ScriptableDataView extends BaseScriptableDataSource {

  public final native func SetSource(source: wref<BaseScriptableDataSource>) -> Void;

  public final native func Filter() -> Void;

  public final native func EnableSorting() -> Void;

  public final native func DisableSorting() -> Void;

  public final native func IsSortingEnabled() -> Bool;

  public final native func Sort() -> Void;

  public func FilterItem(data: ref<IScriptable>) -> Bool {
    return true;
  }

  public func SortItem(left: ref<IScriptable>, right: ref<IScriptable>) -> Bool {
    return true;
  }
}

public native class WeakScriptableDataView extends BaseWeakScriptableDataSource {

  public final native func SetSource(source: wref<BaseWeakScriptableDataSource>) -> Void;

  public final native func Filter() -> Void;

  public final native func EnableSorting() -> Void;

  public final native func DisableSorting() -> Void;

  public final native func IsSortingEnabled() -> Bool;

  public final native func Sort() -> Void;

  public func FilterItem(data: wref<IScriptable>) -> Bool {
    return true;
  }

  public func SortItem(left: wref<IScriptable>, right: wref<IScriptable>) -> Bool {
    return true;
  }
}
