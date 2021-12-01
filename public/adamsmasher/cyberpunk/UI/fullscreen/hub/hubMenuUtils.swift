
public class HubMenuUtils extends IScriptable {

  public final static func SetMenuData(menuButton: inkWidgetRef, identifier: HubMenuItems, parentIdentifier: HubMenuItems, fullscreenName: CName, icon: CName, labelKey: CName, opt userData: ref<IScriptable>) -> ref<MenuItemController> {
    let data: MenuData;
    data.label = GetLocalizedTextByKey(labelKey);
    data.icon = icon;
    data.fullscreenName = fullscreenName;
    data.identifier = EnumInt(identifier);
    data.parentIdentifier = EnumInt(parentIdentifier);
    data.userData = userData;
    let menuItemLogicController: ref<MenuItemController> = inkWidgetRef.GetController(menuButton) as MenuItemController;
    menuItemLogicController.Init(data);
    return menuItemLogicController;
  }

  public final static func SetMenuData(menuButton: inkWidgetRef, data: MenuData) -> ref<MenuItemController> {
    let menuItemLogicController: ref<MenuItemController> = inkWidgetRef.GetController(menuButton) as MenuItemController;
    menuItemLogicController.Init(data);
    return menuItemLogicController;
  }

  public final static func SetMenuHyperlinkData(menuButton: inkWidgetRef, identifier: HubMenuItems, parentIdentifier: HubMenuItems, fullscreenName: CName, icon: CName, labelKey: CName, opt userData: ref<IScriptable>) -> ref<MenuItemController> {
    let menuItemLogicController: ref<MenuItemController> = HubMenuUtils.SetMenuData(menuButton, identifier, parentIdentifier, fullscreenName, icon, labelKey, userData);
    menuItemLogicController.SetHyperlink(true);
    return menuItemLogicController;
  }
}
