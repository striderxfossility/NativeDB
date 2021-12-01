
public class PingSystemMappinController extends BaseInteractionMappinController {

  protected cb func OnIntro() -> Bool {
    let stateName: String;
    let pingMappin: wref<PingSystemMappin> = this.GetMappin() as PingSystemMappin;
    let pingType: gamedataPingType = pingMappin.pingType;
    let pingString: String = EnumValueToString("gamedataPingType", Cast(EnumInt(pingType)));
    let pingTDBID: TweakDBID = TDBID.Create("PingTypes." + pingString);
    let pingRecord: ref<Ping_Record> = TweakDBInterface.GetPingRecord(pingTDBID);
    inkImageRef.SetTexturePart(this.iconWidget, pingRecord.WorldIconName());
    stateName = pingMappin.ResolveIconState();
    inkWidgetRef.SetState(this.iconWidget, StringToName(stateName));
  }
}
