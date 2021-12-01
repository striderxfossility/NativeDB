
public class ItemDisplayUtils extends IScriptable {

  public final static func SpawnCommonSlot(logicController: ref<inkLogicController>, parent: ref<inkWidget>, slotName: CName) -> wref<inkWidget> {
    if IsDefined(parent) {
      return logicController.SpawnFromExternal(parent, r"base\\gameplay\\gui\\common\\components\\slots.inkwidget", slotName);
    };
    return null;
  }

  public final static func SpawnCommonSlot(logicController: ref<inkLogicController>, parent: inkWidgetRef, slotName: CName) -> wref<inkWidget> {
    if IsDefined(inkWidgetRef.Get(parent)) {
      return logicController.SpawnFromExternal(inkWidgetRef.Get(parent), r"base\\gameplay\\gui\\common\\components\\slots.inkwidget", slotName);
    };
    return null;
  }

  public final static func SpawnCommonSlotController(logicController: ref<inkLogicController>, parent: ref<inkWidget>, slotName: CName) -> wref<inkLogicController> {
    if IsDefined(parent) {
      return logicController.SpawnFromExternal(parent, r"base\\gameplay\\gui\\common\\components\\slots.inkwidget", slotName).GetController();
    };
    return null;
  }

  public final static func AsyncSpawnCommonSlotController(logicController: ref<inkLogicController>, parent: ref<inkWidget>, slotName: CName, callbackName: CName, opt userData: ref<IScriptable>) -> Void {
    if IsDefined(parent) {
      logicController.AsyncSpawnFromExternal(parent, r"base\\gameplay\\gui\\common\\components\\slots.inkwidget", slotName, logicController, callbackName, userData);
    };
  }

  public final static func SpawnCommonSlotController(logicController: ref<inkLogicController>, parent: inkWidgetRef, slotName: CName) -> wref<inkLogicController> {
    if IsDefined(inkWidgetRef.Get(parent)) {
      return logicController.SpawnFromExternal(inkWidgetRef.Get(parent), r"base\\gameplay\\gui\\common\\components\\slots.inkwidget", slotName).GetController();
    };
    return null;
  }

  public final static func SpawnCommonSlotAsync(logicController: ref<inkLogicController>, parent: inkWidgetRef, slotName: CName, opt callBack: CName, opt userData: ref<IScriptable>) -> Void {
    if IsDefined(inkWidgetRef.Get(parent)) {
      logicController.AsyncSpawnFromExternal(inkWidgetRef.Get(parent), r"base\\gameplay\\gui\\common\\components\\slots.inkwidget", slotName, logicController, callBack, userData);
    };
  }

  public final static func SpawnCommonSlot(gameController: ref<inkIGameController>, parent: ref<inkWidget>, slotName: CName) -> wref<inkWidget> {
    if IsDefined(parent) {
      return gameController.SpawnFromExternal(parent, r"base\\gameplay\\gui\\common\\components\\slots.inkwidget", slotName);
    };
    return null;
  }

  public final static func SpawnCommonSlot(gameController: ref<inkIGameController>, parent: inkWidgetRef, slotName: CName) -> wref<inkWidget> {
    if IsDefined(inkWidgetRef.Get(parent)) {
      return gameController.SpawnFromExternal(inkWidgetRef.Get(parent), r"base\\gameplay\\gui\\common\\components\\slots.inkwidget", slotName);
    };
    return null;
  }

  public final static func SpawnCommonSlotController(gameController: ref<inkIGameController>, parent: ref<inkWidget>, slotName: CName) -> wref<inkLogicController> {
    if IsDefined(parent) {
      return gameController.SpawnFromExternal(parent, r"base\\gameplay\\gui\\common\\components\\slots.inkwidget", slotName).GetController();
    };
    return null;
  }

  public final static func SpawnCommonSlotController(gameController: ref<inkIGameController>, parent: inkWidgetRef, slotName: CName) -> wref<inkLogicController> {
    if IsDefined(inkWidgetRef.Get(parent)) {
      return gameController.SpawnFromExternal(inkWidgetRef.Get(parent), r"base\\gameplay\\gui\\common\\components\\slots.inkwidget", slotName).GetController();
    };
    return null;
  }

  public final static func AsyncSpawnCommonSlot(gameController: ref<inkIGameController>, parent: ref<inkWidget>, slotName: CName, opt callBack: CName, opt userData: ref<IScriptable>) -> Void {
    if IsDefined(parent) {
      gameController.AsyncSpawnFromExternal(parent, r"base\\gameplay\\gui\\common\\components\\slots.inkwidget", slotName, gameController, callBack, userData);
    };
  }
}
