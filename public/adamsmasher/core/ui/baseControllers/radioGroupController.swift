
public native class inkRadioGroupController extends inkLogicController {

  public final native func AddToggle(toAdd: wref<inkToggleController>) -> Void;

  public final func AddToggles(toAdd: array<wref<inkToggleController>>) -> Void {
    let i: Int32 = 0;
    let limit: Int32 = ArraySize(toAdd);
    while i < limit {
      this.AddToggle(toAdd[i]);
      i += 1;
    };
  }

  public final native func RemoveToggleController(toRemove: wref<inkToggleController>) -> Void;

  public final native func RemoveToggle(index: Int32) -> Void;

  public final native func GetIndexForToggle(controller: wref<inkToggleController>) -> Int32;

  public final native func Toggle(toToggle: Int32) -> Void;

  public final native func GetCurrentIndex() -> Int32;

  public final native func GetController(index: Int32) -> wref<inkToggleController>;

  public final native func GetControllers(out controllers: array<wref<inkToggleController>>) -> Void;
}
