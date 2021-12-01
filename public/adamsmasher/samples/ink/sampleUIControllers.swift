
public class sampleStyleManagerGameController extends inkGameController {

  public edit let m_stylePath1: ResRef;

  public edit let m_stylePath2: ResRef;

  public edit let m_content: inkWidgetRef;

  protected cb func OnInitialize() -> Bool {
    this.GetController(inkWidgetPath.Build(n"stateContainer", n"state1Button")).RegisterToCallback(n"OnRelease", this, n"OnState1");
    this.GetController(inkWidgetPath.Build(n"stateContainer", n"state2Button")).RegisterToCallback(n"OnRelease", this, n"OnState2");
    this.GetController(inkWidgetPath.Build(n"stateContainer", n"state3Button")).RegisterToCallback(n"OnRelease", this, n"OnState3");
    this.GetController(inkWidgetPath.Build(n"styleContainer", n"style1Button")).RegisterToCallback(n"OnRelease", this, n"OnStyle1");
    this.GetController(inkWidgetPath.Build(n"styleContainer", n"style2Button")).RegisterToCallback(n"OnRelease", this, n"OnStyle2");
  }

  protected cb func OnState1(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetState(this.m_content, n"Default");
  }

  protected cb func OnState2(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetState(this.m_content, n"Green");
  }

  protected cb func OnState3(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetState(this.m_content, n"Blue");
  }

  protected cb func OnStyle1(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetStyle(this.m_content, this.m_stylePath1);
  }

  protected cb func OnStyle2(e: ref<inkPointerEvent>) -> Bool {
    inkWidgetRef.SetStyle(this.m_content, this.m_stylePath2);
  }
}

public class sampleUIPathAndReferenceGameController extends inkGameController {

  public edit let m_textWidget: inkTextRef;

  public edit let m_imageWidgetPath: inkWidgetPath;

  private let m_imageWidget: wref<inkImage>;

  private let m_panelWidget: wref<inkBasePanel>;

  protected cb func OnInitialize() -> Bool {
    if inkWidgetRef.IsValid(this.m_textWidget) {
      inkTextRef.SetText(this.m_textWidget, "Hello World!");
    };
    this.m_imageWidget = this.GetWidget(this.m_imageWidgetPath) as inkImage;
    this.m_panelWidget = this.GetWidget(inkWidgetPath.Build(n"container", n"pane;")) as inkBasePanel;
  }
}

public class sampleUIStatusWidgetLogicController extends inkLogicController {

  public edit let enableStateColor: Color;

  public edit let disableStateColor: Color;

  private let m_textWidget: wref<inkText>;

  private let m_iconWidget: wref<inkRectangle>;

  protected cb func OnInitialize() -> Bool {
    this.m_textWidget = this.GetWidget(n"statusText") as inkText;
    this.m_iconWidget = this.GetWidget(n"statusIcon") as inkRectangle;
    this.SetStatus(false);
  }

  public final func SetStatus(on: Bool) -> Void {
    let statusColor: Color;
    let statusText: String;
    if on {
      statusText = "ON";
      statusColor = this.enableStateColor;
    } else {
      statusText = "OFF";
      statusColor = this.disableStateColor;
    };
    this.m_textWidget.SetText(statusText);
    this.m_iconWidget.SetTintColor(statusColor);
  }
}

public class sampleUIInteractionWidgetLogicController extends inkLogicController {

  public edit let enableStateColor: Color;

  public edit let disableStateColor: Color;

  private let m_textWidget: wref<inkText>;

  protected cb func OnInitialize() -> Bool {
    this.m_textWidget = this.GetWidget(n"valueText") as inkText;
  }

  public final func SetIsInteracting(interacting: Bool) -> Void {
    let displayColor: Color;
    let displayText: String;
    if interacting {
      displayText = "Yes";
      displayColor = this.enableStateColor;
    } else {
      displayText = "No";
      displayColor = this.disableStateColor;
    };
    this.m_textWidget.SetText(displayText);
    this.m_textWidget.SetTintColor(displayColor);
  }
}

public class sampleStylesGameController extends inkGameController {

  private let m_stateText: wref<inkText>;

  private let m_button1Controller: wref<inkButtonController>;

  private let m_button2Controller: wref<inkButtonController>;

  protected cb func OnInitialize() -> Bool {
    this.m_stateText = this.GetWidget(n"StateTransitionText") as inkText;
    this.m_button1Controller = this.GetController(n"Button1") as inkButtonController;
    this.m_button1Controller.RegisterToCallback(n"OnButtonStateChanged", this, n"OnButton1StateChanged");
    this.m_button2Controller = this.GetController(n"Button2") as inkButtonController;
    this.m_button2Controller.RegisterToCallback(n"OnRelease", this, n"OnButton2Pressed");
  }

  protected cb func OnButton1StateChanged(controller: wref<inkButtonController>, oldState: inkEButtonState, newState: inkEButtonState) -> Bool {
    this.m_stateText.SetText(this.ButtonStateToString(oldState) + " >> " + this.ButtonStateToString(newState));
  }

  protected cb func OnButton2Pressed(e: ref<inkPointerEvent>) -> Bool {
    let isEnabled: Bool;
    if e.IsAction(n"click") {
      isEnabled = this.m_button1Controller.GetEnabled();
      this.m_button1Controller.SetEnabled(!isEnabled);
    };
  }

  private final func ButtonStateToString(state: inkEButtonState) -> String {
    switch state {
      case inkEButtonState.Normal:
        return "Normal";
      case inkEButtonState.Press:
        return "Press";
      case inkEButtonState.Hover:
        return "Hover";
      case inkEButtonState.Disabled:
        return "Disabled";
    };
    return "";
  }
}

public class sampleScreenProjectionGameController extends inkProjectedHUDGameController {

  private let m_OnTargetHitCallback: ref<CallbackHandle>;

  protected cb func OnInitialize() -> Bool {
    let blackboardSystem: ref<BlackboardSystem> = this.GetBlackboardSystem();
    let blackboard: ref<IBlackboard> = blackboardSystem.Get(GetAllBlackboardDefs().UI_ActiveWeaponData);
    this.m_OnTargetHitCallback = blackboard.RegisterListenerVariant(GetAllBlackboardDefs().UI_ActiveWeaponData.TargetHitEvent, this, n"OnTargetHit");
  }

  protected cb func OnTargetHit(value: Variant) -> Bool {
    let screenProjectionData: inkScreenProjectionData;
    let targetHitData: ref<gameTargetHitEvent> = FromVariant(value);
    let targetController: wref<sampleScreenProjectionLogicController> = this.SpawnFromLocal(this.GetRootWidget(), n"Target").GetController() as sampleScreenProjectionLogicController;
    screenProjectionData.entity = targetHitData.target;
    screenProjectionData.slotComponentName = n"Item_Attachment_Slot";
    screenProjectionData.slotName = n"Head";
    screenProjectionData.fixedWorldOffset = new Vector4(0.00, 0.00, 0.50, 0.00);
    screenProjectionData.userData = targetController;
    let projection: ref<inkScreenProjection> = this.RegisterScreenProjection(screenProjectionData);
    targetController.SetProjection(projection);
    targetController.RegisterToCallback(n"OnReadyToRemove", this, n"OnRemoveTarget");
  }

  protected cb func OnScreenProjectionUpdate(projections: ref<gameuiScreenProjectionsData>) -> Bool {
    let controller: ref<sampleScreenProjectionLogicController>;
    let projection: ref<inkScreenProjection>;
    let count: Int32 = ArraySize(projections.data);
    let i: Int32 = 0;
    while i < count {
      projection = projections.data[i];
      controller = projection.GetUserData() as sampleScreenProjectionLogicController;
      controller.UpdatewidgetPosition(projection);
      i += 1;
    };
  }

  protected cb func OnRemoveTarget(targetWidget: wref<inkWidget>) -> Bool {
    let rootWidget: wref<inkCompoundWidget>;
    let targetController: ref<sampleScreenProjectionLogicController> = targetWidget.GetController() as sampleScreenProjectionLogicController;
    this.UnregisterScreenProjection(targetController.GetProjection());
    rootWidget = this.GetRootWidget() as inkCompoundWidget;
    rootWidget.RemoveChild(targetWidget);
  }
}

public class sampleScreenProjectionLogicController extends inkLogicController {

  private let m_widgetPos: wref<inkText>;

  private let m_worldPos: wref<inkText>;

  private let m_projection: ref<inkScreenProjection>;

  protected cb func OnInitialize() -> Bool {
    this.GetRootWidget().SetAnchorPoint(new Vector2(0.50, 0.50));
    this.m_widgetPos = this.GetWidget(n"widgetPos") as inkText;
    this.m_worldPos = this.GetWidget(n"worldPos") as inkText;
    this.PlayAnimation();
  }

  public final func GetProjection() -> ref<inkScreenProjection> {
    return this.m_projection;
  }

  public final func SetProjection(projection: ref<inkScreenProjection>) -> Void {
    this.m_projection = projection;
  }

  public final func UpdatewidgetPosition(projection: ref<inkScreenProjection>) -> Void {
    let margin: inkMargin;
    let rootWidget: wref<inkWidget> = this.GetRootWidget();
    let gameEntity: ref<GameEntity> = projection.GetEntity() as GameEntity;
    let widgetPosition: Vector2 = projection.currentPosition;
    let worldPosition: Vector4 = gameEntity.GetWorldPosition() + projection.GetFixedWorldOffset();
    margin.left = widgetPosition.X;
    margin.top = widgetPosition.Y;
    rootWidget.SetMargin(margin);
    this.m_widgetPos.SetText("Screen: (" + widgetPosition.X + "," + widgetPosition.Y + ")");
    this.m_worldPos.SetText("World: (" + worldPosition.X + "," + worldPosition.Y + "," + worldPosition.Z + ")");
    rootWidget.SetVisible(projection.IsInScreen());
  }

  private final func PlayAnimation() -> Void {
    let animProxy: ref<inkAnimProxy>;
    let anim: ref<inkAnimDef> = new inkAnimDef();
    let alphaInterpolator: ref<inkAnimTransparency> = new inkAnimTransparency();
    alphaInterpolator.SetStartTransparency(1.00);
    alphaInterpolator.SetEndTransparency(0.00);
    alphaInterpolator.SetDuration(3.00);
    alphaInterpolator.SetType(inkanimInterpolationType.Linear);
    alphaInterpolator.SetMode(inkanimInterpolationMode.EasyIn);
    anim.AddInterpolator(alphaInterpolator);
    animProxy = this.GetRootWidget().PlayAnimation(anim);
    animProxy.RegisterToCallback(inkanimEventType.OnFinish, this, n"OnAnimFinished");
  }

  protected cb func OnAnimFinished(proxy: ref<inkAnimProxy>) -> Bool {
    this.CallCustomCallback(n"OnReadyToRemove");
  }
}
