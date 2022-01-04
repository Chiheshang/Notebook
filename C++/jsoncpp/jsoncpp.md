Jsoncpp 官网 https://github.com/open-source-parsers/jsoncpp

jsoncpp 主要包含三种类型的 class：Value、Reader、Writer。jsoncpp 中所有对象、类名都在 namespace Json 中，包含 json.h 即可。

Json::Value 只能处理 ANSI 类型的字符串，如果 C++ 程序是用 Unicode 编码的，最好加一个 Adapt 类来适配。
1. 从字符串解析json
```c++
int ReadJsonFromString(const string str)
{
    str = "{\"uploadid\": \"UP000000\",\"code\": 100,\"msg\": \"\",\"files\": \"\"}";  

    Json::Reader reader;  
    Json::Value root;  
    if (reader.parse(str, root))  // reader将Json字符串解析到root，root将包含Json里所有子元素  
    {  
        std::string upload_id = root["uploadid"].asString();  // 访问节点，upload_id = "UP000000"  
        int code = root["code"].asInt();    // 访问节点，code = 100 
    }
}
    
```
2. 从文件解析json
```c++
int ReadJsonFromFile(const char* filename)  
{  
    Json::Reader reader;// 解析json用Json::Reader   
    Json::Value root; // Json::Value是一种很重要的类型，可以代表任意类型。如int, string, object, array         

    std::ifstream is;  
    is.open (filename, std::ios::binary );    
    if (reader.parse(is, root, FALSE))  
    {  
        std::string code;  
        if (!root["files"].isNull())  // 访问节点，Access an object value by name, create a null member if it does not exist.  
            code = root["uploadid"].asString();  
        
        code = root.get("uploadid", "null").asString();// 访问节点，Return the member named key if it exist, defaultValue otherwise.    

        int file_size = root["files"].size();  // 得到"files"的数组个数  
        for(int i = 0; i < file_size; ++i)  // 遍历数组  
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
Json::Value 用来表示Json中的任何一种value抽象数据类型，具体来说，Json中的value可以是一下数据类型：

+ 有符号整数 signed integer [range: Value::minInt - Value::maxInt]
+ 无符号整数 unsigned integer (range: 0 - Value::maxUInt)
+ 双精度浮点数 double
+ 字符串 UTF-8 string
+ 布尔型 boolean
+ 空 ‘null’
+ 一个Value的有序列表 an ordered list of Value
+ collection of name/value pairs (javascript object)
可以通过[]的方法来取值。
## Json::Reader
Json::Reader可以通过对Json源目标进行解析，得到一个解析好了的Json::Value，通常字符串或者文件输入流可以作为源目标。

假设现在有一个example.json文件
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
#### 使用Json::Reader对Json文件进行解析：
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
#### 使用Json::Reader对字符串进行解析
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
Json::Writer 和 Json::Reader相反，是把Json::Value对象写到string对象中，而且Json::Writer是个抽象类，被两个子类Json::FastWriter和Json::StyledWriter继承。
简单来说FastWriter就是无格式的写入，这样的Json看起来很乱没有格式，而StyledWriter就是带有格式的写入，看起来会比较友好。
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
结果：
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
Jsoncpp 其他操作
通过前面介绍的Json::value, Json::Reader, Json::Reader 可以实现对Json文件的基本操作，下面介绍一些其他的常用的操作。

#### 判断key是否存在
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
#### 判断Value是否为null
首先要给example.json添加一个key-value对：
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
判断是否为null的成员函数
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
另外值得强调的是，Json::Value和C++中的map有一个共同的特点，就是当你尝试访问一个不存在的 key 时，会自动生成这样一个key-value默认为null的值对。也就是说
```c++
 root["anything-not-exist"].isNull(); //false
 root.isMember("anything-not-exist"); //true
```
总结就是要判断是否含有key，使用isMember成员函数，value是否为null使用isNull成员函数，value是否为空可以用empty() 和 size()成员函数。

#### 得到所有的key
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
可以看到Json::Value::Members实际上就是一个值为string的vector，通过getMemberNames得到所有的key。

#### 删除成员
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