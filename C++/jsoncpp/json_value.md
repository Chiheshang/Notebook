## json::value
常用方法：
#### type()
```c++
int GetJsonInt(const Json::Value& _jsValue)
{
	if ( _jsValue.type() == Json::intValue)
		return _jsValue.asInt();
	else if (_jsValue.type() == Json::stringValue)
		return atoi(_jsValue.asCString());
	else if (_jsValue.isBool())
		return (int)_jsValue.asBool();
	return 0;
}
```
#### get()
```c++
static interface::ModuleMeta load_module_meta(const json::Value &v)
{
	interface::ModuleMeta r;
	r.disable_cpp = v.get("disable_cpp").as_boolean();
	r.cxxflags = v.get("cxxflags").as_string();
	r.ldflags = v.get("ldflags").as_string();
}
```
#### empty()
return size==0?true:false
#### isInt()
```
Json::Value& values
if (values.isInt())
    outValues.emplace_back(values.asInt());
```
#### isMember()
```c++
void Animation::parsePrefab(json::Value& val)
{
	if(val.isMember("sequences") && !val["sequences"].empty())
	{
		json::Value sequences = val["sequences"];

		for(json::Value::iterator it = sequences.begin(); it != sequences.end(); ++it)
		{
			if(!(*it).isMember("start") || !(*it).isMember("end") || !(*it).isMember("fps"))
			{
				szerr << "Animation sequence definition must have start and end frame and fps value." << ErrorStream::error;
				continue;
			}

			sf::Uint32 start	= (*it)["start"].asUInt();
			sf::Uint32 end		= (*it)["end"].asUInt();
			sf::Uint32 fps		= (*it)["fps"].asUInt();

			bool looping		= (*it).get("looping", 0).asBool();
			std::string next	= (*it).get("next", "").asString();

			defineAnimation(it.memberName(), start, end, fps, looping, next);
		}
	}
}
```
#### clear()
Remove all object members and array elements.

Precondition
    type() is arrayValue, objectValue, or nullValue
Postcondition
    type() is unchanged
#### getMemberNames()
Return a list of the member names.

If null, return an empty list.
```c++
    Json::Value fields;
    Json::Value::Members fldid = fields.getMemberNames();
    for(i = 0;i < fldid.size();++i)
	{
		idx = atoi(fldid[i].c_str());
		std::string v = fields.get(fldid[i],"Unknown").asString();
		m_cardfield.insert(CARD_FILED_MAP::value_type(idx,v));
	}
```
#### as
asUInt (),asString (),asInt (),asBool(),asCString()……
#### is
isInt(),isMember(),isArray()……
isValidIndex()Return true if index < size().
