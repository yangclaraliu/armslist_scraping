import urllib2
import pandas as pd
import time
from bs4 import BeautifulSoup

gun = ["http://www.armslist.com/posts/"+str(i) for i in range(7752358,7752365)]  
data = []
for pg in gun:
    page = urllib2.urlopen(pg)
    soup = BeautifulSoup(page)
    title = soup.find("h1").text.strip() if soup.find("h1") else "no type"
    loc = soup.find("div", attrs={"class":"col-sm-12 col-md-7"}).text.strip() if soup.find("div", attrs={"class":"col-sm-12 col-md-7"}) else "no type"
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
        else: "no type"
        
        if "Caliber" in avai:
            caliber = cat.split("\n\n")[avai.index("Caliber")].split("\n\r\n")[1]
        else: "no type"

        if "Action" in avai:
            act = cat.split("\n\n")[avai.index("Action")].split("\n\r\n")[1]
        else: "no type"
                    
        if "Firearm Type" in avai:
            ftype = cat.split("\n\n")[avai.index("Firearm Type")].split("\n\r\n")[1]
        else: "no type"
        
        if "Manufacturer" in avai:
            man = cat.split("\n\n")[avai.index("Manufacturer")].split("\n\r\n")[1]
        else: "no type"
        
    data.append((pg,title,loc,price,postdate,category,man,caliber,act,ftype,postcontent))
    time.sleep(2)
table = pd.DataFrame(data)
table.columns = ['url', 'title','location','price','post date','category','manufacturer','caliber','action','firearm type','postcontent']
table = table[table.title != 'Unrecognized Request']
path = r'C:\liux3204\Documents\Github\SPHStudentProject'
table.to_csv("C:\Users\liux3204\Documents\GitHub\SPHStudentProject\strange.csv", sep=',',encoding='utf-8')