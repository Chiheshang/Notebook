Jsoncpp ���� https://github.com/open-source-parsers/jsoncpp

jsoncpp ��Ҫ�����������͵� class��Value��Reader��Writer��jsoncpp �����ж����������� namespace Json �У����� json.h ���ɡ�

Json::Value ֻ�ܴ��� ANSI ���͵��ַ�������� C++ �������� Unicode ����ģ���ü�һ�� Adapt �������䡣
1. ���ַ�������json
```c++
int ReadJsonFromString(const string str)
{
    str = "{\"uploadid\": \"UP000000\",\"code\": 100,\"msg\": \"\",\"files\": \"\"}";  

    Json::Reader reader;  
    Json::Value root;  
    if (reader.parse(str, root))  // reader��Json�ַ���������root��root������Json��������Ԫ��  
    {  
        std::string upload_id = root["uploadid"].asString();  // ���ʽڵ㣬upload_id = "UP000000"  
        int code = root["code"].asInt();    // ���ʽڵ㣬code = 100 
    }
}
    
```
2. ���ļ�����json
```c++
int ReadJsonFromFile(const char* filename)  
{  
    Json::Reader reader;// ����json��Json::Reader   
    Json::Value root; // Json::Value��һ�ֺ���Ҫ�����ͣ����Դ����������͡���int, string, object, array         

    std::ifstream is;  
    is.open (filename, std::ios::binary );    
    if (reader.parse(is, root, FALSE))  
    {  
        std::string code;  
        if (!root["files"].isNull())  // ���ʽڵ㣬Access an object value by name, create a null member if it does not exist.  
            code = root["uploadid"].asString();  
        
        code = root.get("uploadid", "null").asString();// ���ʽڵ㣬Return the member named key if it exist, defaultValue otherwise.    

        int file_size = root["files"].size();  // �õ�"files"���������  
        for(int i = 0; i < file_size; ++i)  // ��������  
        {  
            Json::Value val_image = root["files"][i]["images"];  
            int image_size = val_image.size();  
            for(int j = 0; j < image_size; ++j)  
            {  
                std::string type = val_image[j]["type"].asString();  
                std::string url  = val_image[j]["url"].asString(); 
                printf("type : %s, url : %s \n", type.c_str(), url.c_str());
            }  
        }  
    }  
    is.close();  

    return 0;  
}
```
## Json::Value
Json::Value ������ʾJson�е��κ�һ��value�����������ͣ�������˵��Json�е�value������һ���������ͣ�

+ �з������� signed integer [range: Value::minInt - Value::maxInt]
+ �޷������� unsigned integer (range: 0 - Value::maxUInt)
+ ˫���ȸ����� double
+ �ַ��� UTF-8 string
+ ������ boolean
+ �� ��null��
+ һ��Value�������б� an ordered list of Value
+ collection of name/value pairs (javascript object)
����ͨ��[]�ķ�����ȡֵ��
## Json::Reader
Json::Reader����ͨ����JsonԴĿ����н������õ�һ���������˵�Json::Value��ͨ���ַ��������ļ�������������ΪԴĿ�ꡣ

����������һ��example.json�ļ�
```json
{
    "encoding" : "UTF-8",
    "plug-ins" : [
        "python",
        "c++",
        "ruby"
        ],
    "indent" : { "length" : 3, "use_space": true }
}
```
#### ʹ��Json::Reader��Json�ļ����н�����
```c++
bool parse (const std::string &document, Value &root, bool collectComments=true)
bool parse (std::istream &is, Value &root, bool collectComments=true) 
```
```c++
Json::Value root;
Json::Reader reader;
std::ifstream ifs("example.json");//open file example.json

if(!reader.parse(ifs, root)){
   // fail to parse
}
else{
   // success
   std::cout<<root["encoding"].asString()<<endl;
   std::cout<<root["indent"]["length"].asInt()<<endl;
```
#### ʹ��Json::Reader���ַ������н���
```c++
bool Json::Reader::parse ( const char * beginDoc,
        const char * endDoc,
        Value & root,
        bool collectComments = true 
    )   
```
```c++
  Json::Value root;
  Json::Reader reader;
  const char* s = "{\"uploadid\": \"UP000000\",\"code\": 100,\"msg\": \"\",\"files\": \"\"}"; 
  if(!reader.parse(s, root)){
    // "parse fail";
  }
  else{
      std::cout << root["uploadid"].asString();//print "UP000000"
  }
```
## Json::Writer
Json::Writer �� Json::Reader�෴���ǰ�Json::Value����д��string�����У�����Json::Writer�Ǹ������࣬����������Json::FastWriter��Json::StyledWriter�̳С�
����˵FastWriter�����޸�ʽ��д�룬������Json����������û�и�ʽ����StyledWriter���Ǵ��и�ʽ��д�룬��������Ƚ��Ѻá�
```c++
Json::Value root;
Json::Reader reader;
Json::FastWriter fwriter;
Json::StyledWriter swriter;

if(! reader.parse("example.json", root)){
// parse fail
    return 0;
}
std::string str = fwriter(root);
std::ofstream ofs("example_fast_writer.json");
ofs << str;
ofs.close();

str = swriter(root);
ofs.open("example_styled_writer.json");
ofs << str;
ofs.close();
```
�����
example_styled_writer.json
```json
{
    "encoding" : "UTF-8",
    "plug-ins" : [
        "python",
        "c++",
        "ruby"
        ],
    "indent" : { "length" : 3, "use_space": true }
}
```
example_fast_writer.json
```json
{"encoding" : "UTF-8","plug-ins" : ["python","c++","ruby"],"indent" : { "length" : 3, "use_space": true}}
```
Jsoncpp ��������
ͨ��ǰ����ܵ�Json::value, Json::Reader, Json::Reader ����ʵ�ֶ�Json�ļ��Ļ����������������һЩ�����ĳ��õĲ�����

#### �ж�key�Ƿ����
```c++
bool Json::Value::isMember ( const char * key) const

Return true if the object has a member named key.

Note
    'key' must be null-terminated. 

bool Json::Value::isMember ( const std::string &  key) const
bool Json::Value::isMember ( const char* key, const char * end ) const
```
```c++
// print "encoding is a member"
if(root.isMember("encoding")){
    std::cout<<"encoding is a member"<<std::endl;
}
else{
    std::cout<<"encoding is not a member"<<std::endl;
}

// print "encode is not a member"
if(root.isMember("encode")){
    std::cout<<"encode is a member"<<std::endl;
}
else{
    std::cout<<"encode is not a member"<<std::endl;
```
#### �ж�Value�Ƿ�Ϊnull
����Ҫ��example.json���һ��key-value�ԣ�
```json
{
    "encoding" : "UTF-8",
    "plug-ins" : [
        "python",
        "c++",
        "ruby"
    ],
    "indent" : { "length" : 3, "use_space": true },
    "tab-length":[],
    "tab":null
}
```
�ж��Ƿ�Ϊnull�ĳ�Ա����
```c++
bool Json::Value::isNull ( ) const
```
```c++
if(root["tab"].isNull()){
    std::cout << "isNull" <<std::endl;//print isNull
}

if(root.isMember("tab-length")){//true
    if(root["tab-length"].isNull()){
      std::cout << "isNull" << std::endl;
    }
    else std::cout << "not Null"<<std::endl;
    // print "not Null", there is a array object([]), through this array object is empty
    std::cout << "empty: " << root["tab-length"].empty() << std::endl;//print empty: 1
    std::cout << "size: " << root["tab-length"].size() << std::endl;//print size: 0
  }
```
����ֵ��ǿ�����ǣ�Json::Value��C++�е�map��һ����ͬ���ص㣬���ǵ��㳢�Է���һ�������ڵ� key ʱ�����Զ���������һ��key-valueĬ��Ϊnull��ֵ�ԡ�Ҳ����˵
```c++
 root["anything-not-exist"].isNull(); //false
 root.isMember("anything-not-exist"); //true
```
�ܽ����Ҫ�ж��Ƿ���key��ʹ��isMember��Ա������value�Ƿ�Ϊnullʹ��isNull��Ա������value�Ƿ�Ϊ�տ�����empty() �� size()��Ա������

#### �õ����е�key
```c++
typedef std::vector<std::string> Json::Value::Members

Value::Members Json::Value::getMemberNames ( ) const

Return a list of the member names.

If null, return an empty list.

Precondition
    type() is objectValue or nullValue 

Postcondition
    if type() was nullValue, it remains nullValue 

```
���Կ���Json::Value::Membersʵ���Ͼ���һ��ֵΪstring��vector��ͨ��getMemberNames�õ����е�key��

#### ɾ����Ա
```c++
Value Json::Value::removeMember( const char* key)   

Remove and return the named member.
Do nothing if it did not exist.

Returns
    the removed Value, or null. 

Precondition
    type() is objectValue or nullValue 

Postcondition
    type() is unchanged 

Value Json::Value::removeMember( const std::string & key)   

bool Json::Value::removeMember( std::string const &key, Value *removed)         

Remove the named map member.
Update 'removed' iff removed.

Parameters
    key may contain embedded nulls.

Returns
    true iff removed (no exceptions) 

```