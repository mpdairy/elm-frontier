var _mpdairy$elm_frontier$Native_Frontier = function() {

  var toJson = function(portFn, elm_obj) {
    return _elm_lang$core$Native_Scheduler.nativeBinding(
      function(callback) {
        var portName = portFn(null).home;
        var converter = _elm_lang$core$Native_Platform.effectManagers[portName].converter;
        try {
          var jsonString = JSON.stringify(converter(elm_obj))
          return callback(_elm_lang$core$Native_Scheduler.succeed(jsonString));
        }
        catch (err) {
          return callback(_elm_lang$core$Native_Scheduler.fail(err));
        }
      })
  };

  var fromJson = function(portFn, json_string) {
    return _elm_lang$core$Native_Scheduler.nativeBinding(
      function(callback) {
        var portName = portFn(null).home;
        var converter = _elm_lang$core$Native_Platform.effectManagers[portName].converter;
        try {
          var retJsObj = JSON.parse(json_string);
        }
        catch (ex) {
          return callback(_elm_lang$core$Native_Scheduler.call(err));
        }
        var retElmObj = A2(_elm_lang$core$Json_Decode$decodeValue, converter, retJsObj);
        if (retElmObj.ctor == "Ok") {
          return callback(_elm_lang$core$Native_Scheduler.succeed(retElmObj._0));
        }
        else {
          return callback(_elm_lang$core$Native_Scheduler.fail(retElmObj._0));
        }
      })
  };

  var call = function(outPortFn, inPortFn, fnName, elmObj) {

    return _elm_lang$core$Native_Scheduler.nativeBinding(
      function(callback)
      {
        var outPort = outPortFn(null).home;
        var inPort = inPortFn(null).home;

        var converter1 = _elm_lang$core$Native_Platform.effectManagers[outPort].converter;
        var jsObj = converter1(elmObj);

        try {
          var jsFn = eval(fnName);
        }
        catch (err) {
          return callback(_elm_lang$core$Native_Scheduler.fail(err));
        }

        var succeedCallback = function(retJsObj) {
          var converter2 = _elm_lang$core$Native_Platform.effectManagers[inPort].converter;

          var retElmObj = A2(_elm_lang$core$Json_Decode$decodeValue, converter2, retJsObj);
          if (retElmObj.ctor == "Ok") {
            return callback(_elm_lang$core$Native_Scheduler.succeed(retElmObj._0));
          }
          else {
            return callback(_elm_lang$core$Native_Scheduler.fail(retElmObj._0));
          }
        }

        var failCallback = function(errorMsg) {
          return callback(_elm_lang$core$Native_Scheduler.fail(errorMsg));
        }
        var ret = { succeed : succeedCallback,
                    fail : failCallback
                    }
        try {
          jsFn(ret, jsObj);
        }
        catch (err) {
          return callback(_elm_lang$core$Native_Scheduler.fail(err));
        }
      });
    /*


    
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
    }*/
  }  
  
  return {
    toJson : F2(toJson),
    fromJson : F2(fromJson),
    call : F4(call)
  };}
();
