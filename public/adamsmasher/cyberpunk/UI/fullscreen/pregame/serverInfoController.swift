
public class ServerInfoController extends ListItemController {

  private let m_settingsListCtrl: wref<ListController>;

  public let m_number: wref<inkText>;

  public edit let m_numberPath: CName;

  private let m_kind: wref<inkText>;

  public edit let m_kindPath: CName;

  private let m_hostname: wref<inkText>;

  public edit let m_hostnamePath: CName;

  private let m_address: wref<inkText>;

  public edit let m_addressPath: CName;

  private let m_worldDescription: wref<inkText>;

  public edit let m_worldDescriptionPath: CName;

  private let m_background: wref<inkImage>;

  private let c_selectionColor: Color;

  private let c_initialColor: HDRColor;

  private let c_markColor: HDRColor;

  @default(ServerInfoController, false)
  private let m_marked: Bool;

  protected cb func OnInitialize() -> Bool {
    super.OnInitialize();
    this.c_selectionColor = new Color(220u, 20u, 60u, 1u);
    this.c_markColor = new HDRColor(0.00, 1.00, 0.00, 1.00);
    this.RegisterToCallback(n"OnSelected", this, n"OnSelected");
    this.RegisterToCallback(n"OnDeselected", this, n"OnDeselected");
    this.m_number = this.GetWidget(this.m_numberPath) as inkText;
    this.m_kind = this.GetWidget(this.m_kindPath) as inkText;
    this.m_hostname = this.GetWidget(this.m_hostnamePath) as inkText;
    this.m_address = this.GetWidget(this.m_addressPath) as inkText;
    this.m_worldDescription = this.GetWidget(this.m_worldDescriptionPath) as inkText;
    this.m_background = this.GetWidget(n"Background") as inkImage;
    this.c_initialColor = this.m_background.GetTintColor();
    this.RegisterToCallback(n"OnHoverOver", this, n"OnHoverOver");
    this.RegisterToCallback(n"OnHoverOut", this, n"OnHoverOut");
    this.RegisterToCallback(n"OnRelease", this, n"OnRelease");
  }

  protected cb func OnDataChanged(data: ref<IScriptable>) -> Bool {
    let serverInfo: ref<ServerInfo> = data as ServerInfo;
    this.m_number.SetText(ToString(serverInfo.number + 1));
    this.m_kind.SetText(serverInfo.kind);
    this.m_hostname.SetText(serverInfo.hostname);
    this.m_address.SetText(serverInfo.address);
    this.m_worldDescription.SetText(serverInfo.worldDescription);
  }

  public final func SetMarked(value: Bool) -> Void {
    this.m_marked = value;
    this.m_background.SetTintColor(this.m_marked ? this.c_markColor : this.c_initialColor);
  }

  public final func IsMarked() -> Bool {
    return this.m_marked;
  }

  protected cb func OnSelected(parent: wref<ListItemController>) -> Bool;

  protected cb func OnDeselected(parent: wref<ListItemController>) -> Bool;

  protected cb func OnRelease(e: ref<inkPointerEvent>) -> Bool {
    this.SetMarked(true);
  }

  protected cb func OnHoverOver(e: ref<inkPointerEvent>) -> Bool {
    if !this.m_marked {
      this.m_background.SetTintColor(this.c_selectionColor);
    };
  }

  protected cb func OnHoverOut(e: ref<inkPointerEvent>) -> Bool {
    if !this.m_marked {
      this.m_background.SetTintColor(this.c_initialColor);
    };
  }
}
