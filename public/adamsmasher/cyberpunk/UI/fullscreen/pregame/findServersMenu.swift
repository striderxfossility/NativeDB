
public class FindServersMenuGameController extends PreGameSubMenuGameController {

  private let m_serversListCtrl: wref<ListController>;

  @default(FindServersMenuGameController, -1)
  private let NONE_CHOOSEN: Int32;

  @default(FindServersMenuGameController, -1)
  private let curentlyChoosenServer: Int32;

  private let m_LANStatusLabel: wref<inkText>;

  private let m_WEBStatusLabel: wref<inkText>;

  private let c_onlineColor: Color;

  private let c_offlineColor: Color;

  private let m_token: wref<inkText>;

  protected cb func OnInitialize() -> Bool {
    let selectorsList: wref<inkVerticalPanel>;
    this.c_onlineColor = new Color(0u, 255u, 0u, 255u);
    this.c_offlineColor = new Color(255u, 0u, 0u, 255u);
    super.OnInitialize();
    this.GetSystemRequestsHandler().RegisterToCallback(n"OnServersSearchResult", this, n"OnServersSearchResult");
    selectorsList = this.GetWidget(n"Data/Table/Rows") as inkVerticalPanel;
    this.m_serversListCtrl = selectorsList.GetController() as ListController;
    this.m_LANStatusLabel = this.GetWidget(n"Data/Table/NetworkStatus/LAN/Status/Status") as inkText;
    this.m_WEBStatusLabel = this.GetWidget(n"Data/Table/NetworkStatus/WEB/Status/Status") as inkText;
    this.m_token = this.GetWidget(n"txtToken") as inkText;
    this.UpdateNetworkStatus();
  }

  public func InitializeMenuName(menuName: wref<inkText>) -> Void {
    menuName.SetText("FIND SERVERS");
  }

  public func InitializeButtons(buttonsList: wref<inkVerticalPanel>) -> Void {
    this.ReInitializeButtons();
  }

  private final func UpdateNetworkStatus() -> Void {
    this.m_LANStatusLabel.SetText("ONLINE BY DEFAULT");
    this.m_LANStatusLabel.SetTintColor(this.c_onlineColor);
    if this.GetSystemRequestsHandler().IsOnline() {
      this.m_WEBStatusLabel.SetText("ONLINE");
      this.m_WEBStatusLabel.SetTintColor(this.c_onlineColor);
    } else {
      this.m_WEBStatusLabel.SetText("OFFLINE");
      this.m_WEBStatusLabel.SetTintColor(this.c_offlineColor);
    };
  }

  protected cb func OnCloudQuickmatch(e: ref<inkPointerEvent>) -> Bool {
    let groupToken: String;
    if e.IsAction(n"click") {
      groupToken = this.m_token.GetText();
      this.GetSystemRequestsHandler().CloudQuickmatch(groupToken);
    };
  }

  protected cb func OnJoin(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.GetSystemRequestsHandler().JoinServer(this.curentlyChoosenServer);
    };
  }

  protected cb func OnLANServers(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.m_serversListCtrl.Clear();
      this.m_serversListCtrl.Refresh();
      this.GetSystemRequestsHandler().RequestLANServers();
      this.ClearButtons();
    };
  }

  protected cb func OnInternetServers(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.m_serversListCtrl.Clear();
      this.m_serversListCtrl.Refresh();
      this.GetSystemRequestsHandler().RequestInternetServers();
      this.ClearButtons();
    };
  }

  protected cb func OnBack(e: ref<inkPointerEvent>) -> Bool {
    if e.IsAction(n"click") {
      this.m_menuEventDispatcher.SpawnEvent(n"OnBack");
    };
  }

  protected cb func OnServersSearchResult(servers: array<ref<ServerInfo>>) -> Bool {
    let _servers: array<ref<IScriptable>>;
    let i: Int32;
    if ArraySize(servers) > 0 {
      i = 0;
      while i < ArraySize(servers) {
        ArrayPush(_servers, servers[i]);
        i += 1;
      };
      this.m_serversListCtrl.PushDataList(_servers, true);
      i = 0;
      while i < ArraySize(servers) {
        this.GetServerInfoController(i).RegisterToCallback(n"OnRelease", this, n"OnServerChoosen");
        i += 1;
      };
    };
    this.curentlyChoosenServer = this.NONE_CHOOSEN;
    this.ReInitializeButtons();
  }

  protected cb func OnServerChoosen(e: ref<inkPointerEvent>) -> Bool {
    let newChoosenServerId: Int32 = this.GetChoosenServerId(this.curentlyChoosenServer);
    if newChoosenServerId != this.NONE_CHOOSEN && this.curentlyChoosenServer != newChoosenServerId {
      if this.curentlyChoosenServer != this.NONE_CHOOSEN {
        this.GetServerInfoController(this.curentlyChoosenServer).SetMarked(false);
      };
      this.curentlyChoosenServer = newChoosenServerId;
      this.GetServerInfoController(this.curentlyChoosenServer).SetMarked(true);
      this.ClearButtons();
      this.ReInitializeButtons();
    };
  }

  private final func GetServerInfoController(i: Int32) -> ref<ServerInfoController> {
    return this.m_serversListCtrl.GetItemAt(i).GetController() as ServerInfoController;
  }

  public final func GetChoosenServerId(omitItem: Int32) -> Int32 {
    let i: Int32 = 0;
    while i < this.m_serversListCtrl.Size() {
      if i == omitItem {
      } else {
        if this.GetServerInfoController(i).IsMarked() {
          return i;
        };
      };
      i += 1;
    };
    return this.NONE_CHOOSEN;
  }

  public final func ClearButtons() -> Void {
    let buttonsList: wref<inkVerticalPanel> = this.GetWidget(n"MainColumn\\Container\\ButtonsList") as inkVerticalPanel;
    buttonsList.RemoveAllChildren();
  }

  public final func ReInitializeButtons() -> Void {
    let buttonsList: wref<inkVerticalPanel> = this.GetWidget(n"MainColumn\\Container\\ButtonsList") as inkVerticalPanel;
    this.AddButtons(buttonsList);
  }

  public final func AddButtons(buttonsList: wref<inkVerticalPanel>) -> Void {
    this.ClearButtons();
    this.AddButton(buttonsList, "CLOUD QUICKMATCH", n"OnCloudQuickmatch");
    if this.curentlyChoosenServer == this.NONE_CHOOSEN {
      this.AddButton(buttonsList, "JOIN SERVER ", n"OnJoin");
      this.Deactivate(this.GetButton(buttonsList, "JOIN SERVER"));
    } else {
      this.AddButton(buttonsList, "JOIN SERVER " + ToString(this.curentlyChoosenServer + 1), n"OnJoin");
    };
    this.AddButton(buttonsList, "FIND LAN SERVERS", n"OnLANServers");
    if this.GetSystemRequestsHandler().IsOnline() {
      this.AddButton(buttonsList, "FIND INTERNET SERVERS", n"OnInternetServers");
    } else {
      this.AddButton(buttonsList, "INTERNET SERVERS UNAVAILABLE", n"OnInternetServers");
      this.Deactivate(this.GetButton(buttonsList, "INTERNET SERVERS UNAVAILABLE"));
    };
    this.AddButton(buttonsList, "BACK", n"OnBack");
  }

  private final func Deactivate(widget: wref<inkWidget>) -> Void {
    widget.SetInteractive(false);
    widget.SetOpacity(0.30);
  }

  private final func GetButton(buttonsList: wref<inkVerticalPanel>, name: String) -> wref<inkWidget> {
    let button: wref<inkWidget>;
    let logicController: wref<inkButtonDpadSupportedController>;
    let i: Int32 = 0;
    while i < buttonsList.GetNumChildren() {
      button = buttonsList.GetWidget(i);
      logicController = button.GetController() as inkButtonDpadSupportedController;
      if Equals(logicController.GetButtonText(), name) {
        return button;
      };
      i += 1;
    };
    return null;
  }
}
