import codecs
import json

file = codecs.open('./trStations.json','r','utf-8')

json_str = file.read()

stations =  json.loads(json_str)

cityList = [
'臺北市Taipei'
,'新北市NewTaipei'
,'桃園市Taoyuan'
,'臺中市Taichung'
,'臺南市Tainan'
,'高雄市Kaohsiung'
,'基隆市Keelung'
,'新竹市Hsinchu'
,'新竹縣HsinchuCounty'
,'苗栗縣MiaoliCounty'
,'彰化縣ChanghuaCounty'
,'南投縣NantouCounty'
,'雲林縣YunlinCounty'
,'嘉義縣ChiayiCounty'
,'嘉義市Chiayi'
,'屏東縣PingtungCounty'
,'宜蘭縣YilanCounty'
,'花蓮縣HualienCounty'
,'臺東縣TaitungCounty'
,'金門縣KinmenCounty'
,'澎湖縣PenghuCounty'
,'連江縣LienchiangCounty'
]

for station in stations:
    for city in cityList:
        if(city[0:3] in station["StationAddress"]):
            station["City"] = city

ofile = codecs.open('./trStationnew.json','w','utf-8')
jsonstr = json.dumps(stations, ensure_ascii=False).encode('utf-8')
print(jsonstr.decode())
ofile.write(jsonstr.decode())

