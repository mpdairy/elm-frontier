var jim = "Hello dougy";

var _mpdairy$elm_frontier$Native_Frontier = function() {

  var toJson = function(portFn, elm_obj) {
    var portName = portFn(null).home;
    if (typeof _elm_lang$core$Native_Platform.effectManagers[portName] == 'undefined')
    {
      throw ("Cannot find port name " + portName);
      return null;
    }
    else {
      var converter = _elm_lang$core$Native_Platform.effectManagers[portName].converter;
      return JSON.stringify(converter(elm_obj));
    }
  };

  var fromJson = function(portFn, json_string) {
    var portName = portFn(null).home;
    var converter = _elm_lang$core$Native_Platform.effectManagers[portName].converter;
    try {
      var incomingValue = JSON.parse(json_string);
      return A2(_elm_lang$core$Json_Decode$decodeValue, converter, incomingValue);
    }
    catch (ex) {
      console.log(ex);
      return A2(_elm_lang$core$Json_Decode$decodeValue, converter, null);
    }
  }

  var responsePort = function(fnName, outPortFn, inPortFn, elmObj) {
    var outPort = outPortFn(null).home;
    var inPort = inPortFn(null).home;
    var jsObj = null;

    window.outPort =  _elm_lang$core$Native_Platform.effectManagers[outPort];
    if (typeof _elm_lang$core$Native_Platform.effectManagers[outPort] == 'undefined')
    {
      throw ("Cannot find outging port name " + outPort);
      jsObj = null;
    }
    else {
      var converter1 = _elm_lang$core$Native_Platform.effectManagers[outPort].converter;
      jsObj = converter1(elmObj);
    }

    var jsFn = eval(fnName);



    var retObj = jsFn(jsObj);

    
    var converter2 = _elm_lang$core$Native_Platform.effectManagers[inPort].converter;
    try {
      //var incomingValue = JSON.parse(json_string);
      return A2(_elm_lang$core$Json_Decode$decodeValue, converter2, retObj);
    }
    catch (ex) {
      console.log(ex);
      return A2(_elm_lang$core$Json_Decode$decodeValue, converter2, null);
    }
  }
  
  return {
    toJson : F2(toJson),
    fromJson : F2(fromJson),
    responsePort : F4(responsePort)
  };}
();
