
public class VehiclesManagerDataHelper extends IScriptable {

  public final static func GetVehicles(player: ref<GameObject>) -> array<ref<IScriptable>> {
    let currnetData: ref<VehicleListItemData>;
    let i: Int32;
    let result: array<ref<IScriptable>>;
    let vehicle: PlayerVehicle;
    let vehicleRecord: ref<Vehicle_Record>;
    let vehiclesList: array<PlayerVehicle>;
    GameInstance.GetVehicleSystem(player.GetGame()).GetPlayerUnlockedVehicles(vehiclesList);
    i = 0;
    while i < ArraySize(vehiclesList) {
      vehicle = vehiclesList[i];
      if TDBID.IsValid(vehicle.recordID) {
        vehicleRecord = TweakDBInterface.GetVehicleRecord(vehicle.recordID);
        currnetData = new VehicleListItemData();
        currnetData.m_displayName = vehicleRecord.DisplayName();
        currnetData.m_icon = vehicleRecord.Icon();
        currnetData.m_data = vehicle;
        ArrayPush(result, currnetData);
      };
      i += 1;
    };
    return result;
  }

  public final static func GetRadioStations(player: ref<GameObject>) -> array<ref<IScriptable>> {
    let res: array<ref<IScriptable>>;
    VehiclesManagerDataHelper.PushRadioStationData(res, TweakDBInterface.GetRadioStationRecord(t"RadioStation.NoStation"));
    VehiclesManagerDataHelper.PushRadioStationData(res, TweakDBInterface.GetRadioStationRecord(t"RadioStation.Downtempo"));
    VehiclesManagerDataHelper.PushRadioStationData(res, TweakDBInterface.GetRadioStationRecord(t"RadioStation.AggroIndie"));
    VehiclesManagerDataHelper.PushRadioStationData(res, TweakDBInterface.GetRadioStationRecord(t"RadioStation.Jazz"));
    VehiclesManagerDataHelper.PushRadioStationData(res, TweakDBInterface.GetRadioStationRecord(t"RadioStation.ElectroIndie"));
    VehiclesManagerDataHelper.PushRadioStationData(res, TweakDBInterface.GetRadioStationRecord(t"RadioStation.MinimTech"));
    VehiclesManagerDataHelper.PushRadioStationData(res, TweakDBInterface.GetRadioStationRecord(t"RadioStation.Metal"));
    VehiclesManagerDataHelper.PushRadioStationData(res, TweakDBInterface.GetRadioStationRecord(t"RadioStation.Pop"));
    VehiclesManagerDataHelper.PushRadioStationData(res, TweakDBInterface.GetRadioStationRecord(t"RadioStation.HipHop"));
    VehiclesManagerDataHelper.PushRadioStationData(res, TweakDBInterface.GetRadioStationRecord(t"RadioStation.AggroTechno"));
    VehiclesManagerDataHelper.PushRadioStationData(res, TweakDBInterface.GetRadioStationRecord(t"RadioStation.Lationo"));
    VehiclesManagerDataHelper.PushRadioStationData(res, TweakDBInterface.GetRadioStationRecord(t"RadioStation.AttRock"));
    return res;
  }

  private final static func PushRadioStationData(out result: array<ref<IScriptable>>, record: ref<RadioStation_Record>) -> Void {
    let stationDataObj: ref<RadioListItemData> = new RadioListItemData();
    stationDataObj.m_record = record;
    ArrayPush(result, stationDataObj);
  }
}
