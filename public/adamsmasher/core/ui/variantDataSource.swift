
public native class VariantDataView extends BaseVariantDataSource {

  public final native func SetSource(source: wref<BaseVariantDataSource>) -> Void;

  public final native func Filter() -> Void;

  public final native func EnableSorting() -> Void;

  public final native func DisableSorting() -> Void;

  public final native func IsSortingEnabled() -> Bool;

  public final native func Sort() -> Void;

  public func FilterItem(data: Variant) -> Bool {
    return true;
  }

  public func SortItem(left: Variant, right: Variant) -> Bool {
    return true;
  }
}
