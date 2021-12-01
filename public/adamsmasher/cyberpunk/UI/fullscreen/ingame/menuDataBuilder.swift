
public class MenuDataBuilder extends IScriptable {

  public let m_data: array<MenuData>;

  public final static func Make() -> ref<MenuDataBuilder> {
    let instance: ref<MenuDataBuilder> = new MenuDataBuilder();
    return instance;
  }

  public final func AddIf(condition: Bool, identifier: Int32, fullscreenName: CName, icon: CName, labelKey: CName, opt userData: ref<IScriptable>) -> ref<MenuDataBuilder> {
    if condition {
      return this.Add(identifier, fullscreenName, icon, labelKey, userData);
    };
    return this;
  }

  public final func Add(identifier: Int32, fullscreenName: CName, icon: CName, labelKey: CName, opt userData: ref<IScriptable>) -> ref<MenuDataBuilder> {
    let data: MenuData;
    data.label = GetLocalizedTextByKey(labelKey);
    data.icon = icon;
    data.fullscreenName = fullscreenName;
    data.identifier = identifier;
    data.userData = userData;
    ArrayPush(this.m_data, data);
    return this;
  }

  public final func Add(identifier: HubMenuItems, parentIdentifier: HubMenuItems, fullscreenName: CName, icon: CName, labelKey: CName, opt userData: ref<IScriptable>, opt disabled: Bool) -> ref<MenuDataBuilder> {
    let data: MenuData;
    data.label = GetLocalizedTextByKey(labelKey);
    data.icon = icon;
    data.fullscreenName = fullscreenName;
    data.identifier = EnumInt(identifier);
    data.parentIdentifier = EnumInt(parentIdentifier);
    data.userData = userData;
    data.disabled = disabled;
    ArrayPush(this.m_data, data);
    return this;
  }

  public final func AddWithSubmenu(identifier: Int32, fullscreenName: CName, icon: CName, labelKey: CName, opt userData: ref<IScriptable>, opt disabled: Bool) -> ref<SubmenuDataBuilder> {
    let data: MenuData;
    data.label = GetLocalizedTextByKey(labelKey);
    data.icon = icon;
    data.fullscreenName = fullscreenName;
    data.identifier = identifier;
    data.userData = userData;
    data.disabled = disabled;
    ArrayPush(this.m_data, data);
    return SubmenuDataBuilder.Make(this, ArraySize(this.m_data) - 1);
  }

  public final func Get() -> array<MenuData> {
    return this.m_data;
  }

  public final func GetMainMenus() -> array<MenuData> {
    let currentData: MenuData;
    let res: array<MenuData>;
    let count: Int32 = ArraySize(this.m_data);
    let i: Int32 = 0;
    while i < count {
      currentData = this.m_data[i];
      if currentData.parentIdentifier == EnumInt(IntEnum(-1l)) {
        ArrayPush(res, currentData);
      };
      i = i + 1;
    };
    return res;
  }

  public final func GetData(identifier: Int32) -> MenuData {
    let res: MenuData;
    let count: Int32 = ArraySize(this.m_data);
    let i: Int32 = 0;
    while i < count {
      res = this.m_data[i];
      if res.identifier == identifier {
        return res;
      };
      i = i + 1;
    };
    res.identifier = EnumInt(IntEnum(-1l));
    return res;
  }

  public final func GetData(fullscreenName: CName) -> MenuData {
    let res: MenuData;
    let count: Int32 = ArraySize(this.m_data);
    let i: Int32 = 0;
    while i < count {
      res = this.m_data[i];
      if Equals(res.fullscreenName, fullscreenName) {
        return res;
      };
      i = i + 1;
    };
    res.identifier = EnumInt(IntEnum(-1l));
    return res;
  }
}

public class SubmenuDataBuilder extends IScriptable {

  private let m_menuBuilder: ref<MenuDataBuilder>;

  private let m_menuDataIndex: Int32;

  public final static func Make(menuBuilder: ref<MenuDataBuilder>, menuDataIndex: Int32) -> ref<SubmenuDataBuilder> {
    let instance: ref<SubmenuDataBuilder> = new SubmenuDataBuilder();
    instance.m_menuDataIndex = menuDataIndex;
    instance.m_menuBuilder = menuBuilder;
    return instance;
  }

  public final func AddSubmenu(identifier: Int32, fullscreenName: CName, labelKey: CName, opt userData: ref<IScriptable>) -> ref<SubmenuDataBuilder> {
    let data: MenuData;
    data.label = GetLocalizedTextByKey(labelKey);
    data.fullscreenName = fullscreenName;
    data.identifier = identifier;
    data.userData = userData;
    ArrayPush(this.m_menuBuilder.m_data[this.m_menuDataIndex].subMenus, data);
    return this;
  }

  public final func AddSubmenuIf(condition: Bool, identifier: Int32, fullscreenName: CName, labelKey: CName, opt userData: ref<IScriptable>) -> ref<SubmenuDataBuilder> {
    if condition {
      return this.AddSubmenu(identifier, fullscreenName, labelKey, userData);
    };
    return this;
  }

  public final func GetMenuBuilder() -> ref<MenuDataBuilder> {
    return this.m_menuBuilder;
  }
}
