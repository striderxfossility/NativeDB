
public class artist_test_area_r extends inkHUDGameController {

  private let m_rootWidget: wref<inkWidget>;

  private let m_linesWidget: wref<inkCanvas>;

  protected cb func OnInitialize() -> Bool {
    let player: ref<PlayerPuppet> = this.GetOwnerEntity() as PlayerPuppet;
    player.RegisterInputListener(this, n"UI_DPadDown");
    this.m_rootWidget = this.GetRootWidget();
    this.m_linesWidget = this.GetWidget(n"Lines") as inkCanvas;
  }

  protected cb func OnAction(action: ListenerAction, consumer: ListenerActionConsumer) -> Bool {
    if Equals(ListenerAction.GetType(action), gameinputActionType.BUTTON_RELEASED) {
      this.PlayLibraryAnimationOnTargets(n"animationNameHere_1", SelectWidgets(this.m_rootWidget));
      this.PlayLibraryAnimationOnTargets(n"animationNameHere_2", SelectWidgets(this.m_linesWidget));
    };
  }
}
