Json������http://www.json.org/json-zh.html

json�н�֧�����ֽṹ��

+ name->value��ֵ�ԣ�pair���ļ��ϣ�һ���Ϊ����object����
+ ֵ�������һ���Ϊ����(array)��
1. pair
�ȴӼ�ֵ�ԣ�pair����ʼ��һ��pair��ͨ���ṹ�ǣ�`string:value`
��ֵ֮��Ķ�Ӧ��ϵʹ��`:`��ʾ����ߵ�Ϊname���ұߵ�Ϊvalue��
һ��keyʹ���ַ�������ȻҲ����ʹ�����֣����ǲ��Ƽ���
value��ȡֵ�ͱȽ���㣬�������κ��κ�json֧�ֵ����ͣ�����object��array��string��number��true/false��null�ȣ���

2. object
object������Ϊ�Ƕ��pair�ļ��ϣ������ϸ�����ʾ��ͼ���£�
![](../../photo/object.png)
���﷨����{��Ϊobject��ʼ����}��Ϊobject��������ͬ��pair֮��ʹ��,�ָ
��Ҫ˵������object�е����ݴ洢������ġ�

������һ���Ƚϵ��͵�object����
```json
{
"name" : "tocy",
"age" : 1000
}
```
3. array
array��value�����򼯺ϡ��ȿ����������array�ṹ��ʾ��ͼ��
![](../../photo/array.png)
���﷨����[��Ϊarray��ʼ����]��Ϊarray������arrayԪ��֮��ʹ��,�ָ
ʵ��ʹ���н�����array��ʹ��ͳһ�����ͣ���������������鷳�㡣
���������﷨�ǺϷ��ģ�
```json
[{"name":"tocy"}, {"age":1000}, {"domain":"cn"}]
```
��Ȼ��������д��Ҳ�ǿ��Եģ�`[1, "ts", true, {"key":45}]`

����������string��number֧�ֵĸ�ʽ������ο�json�ٷ����ܡ�