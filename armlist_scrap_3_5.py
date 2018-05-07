import urllib.request, urllib.error, urllib.parse
import pandas as pd
import time
import os

from bs4 import BeautifulSoup

os.chdir("C:\\Users\\liux3204\\Documents\\GitHub\\SPHStudentProject")

start = 7000000 #need to change based on the number you were given
begin = list(range(start,start+999999,1000))
end = list(range(start+999, start+1000000,1000))
initial = 'YL' #need to change based on your initial


for record in range(len(begin)):
    t0 = time.time()
    gun = ["http://www.armslist.com/posts/"+str(i) for i in range(begin[record],end[record])]  
    data = []
    for pg in gun:
        page = urllib.request.urlopen(pg)
        soup = BeautifulSoup(page)
        title = soup.find("h1").text.strip() if soup.find("h1") else "no type"
#       loc = soup.find("ul",attrs={"class":"location"}).find("div",attrs={"class":"col-sm-12 col-md-7"}).text.strip() if soup.find("ul",attrs={"class":"location"}) else "no type"
        location = soup.findAll("ul",attrs={"class":"location"})
        if location:
            l1=[0]*len(location)
            for i in range(len(location)):
                l1[i] = location[i].text
            l2 = [_f for _f in ''.join(l1).splitlines() if _f]
            loc = l2[l2.index(" Location:")+1]
        else: 
            loc = "no type"                            
        price = soup.find("span", attrs={"class":"price"}).text.strip() if soup.find("span", attrs={"class":"price"}) else "no type"
        postdate = soup.find("span", attrs={"class":"date"}).text.strip() if soup.find("span", attrs={"class":"date"}) else "no type"
        postcontent = soup.find("div", attrs={"class":"postContent"}).text.strip() if soup.find("div", attrs={"class":"postContent"}) else "no type"
        cat = soup.find("ul", attrs={"class":"category"}).text.strip() if soup.find("ul", attrs={"class":"category"}) else "no type"
        if cat == "no type":
            category = "no type"
            man = "no type"
            caliber = "no type"
            ftype = "no type"
            act = "no type"
        else: 
            no = len(cat.split("\n\n"))
            avai = [None]*no
            for i in range(no):
                avai[i] =  cat.split("\n\n\n")[i].split("\n")[0]
            if "CATEGORY" in avai:
                category = cat.split("\n\n")[avai.index("CATEGORY")].split()[1]
            else: 
                category = "no type"
            
            if "Caliber" in avai:
                caliber = cat.split("\n\n")[avai.index("Caliber")].split("\n\r\n")[1]
            else: 
                caliber = "no type"
    
            if "Action" in avai:
                act = cat.split("\n\n")[avai.index("Action")].split("\n\r\n")[1]
            else:
                act = "no type"
                        
            if "Firearm Type" in avai:
                ftype = cat.split("\n\n")[avai.index("Firearm Type")].split("\n\r\n")[1]
            else: 
                ftype = "no type"
            
            if "Manufacturer" in avai:
                man = cat.split("\n\n")[avai.index("Manufacturer")].split("\n\r\n")[1]
            else: 
                man = "no type"
            
        data.append((pg,title,loc,price,postdate,category,man,caliber,act,ftype,postcontent))
        time.sleep(0.5)
    table = pd.DataFrame(data)
    table.columns = ['url', 'title','location','price','post date','category','manufacturer','caliber','action','firearm type','postcontent']
    table = table[table.title != 'Unrecognized Request']
    table = table[table.title != 'no type']
    table.to_csv(''.join([initial,'_',str(begin[record]),'_',str(end[record]),'.csv']), sep=',',encoding='utf-8')
    t1 = time.time()
    total = t1-t0
