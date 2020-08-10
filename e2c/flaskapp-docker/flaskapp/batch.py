
from datetime import timezone
from datetime import datetime
import datetime
import requests

from backend.communicate import Communicate

import time
import atexit


def get_data(docs):
    users = {}
    for doc in docs:
        d = doc.to_dict()
        try:
            date_of_seed = d["seed"].timestamp_pb().ToSeconds()

            date_of_trans = d["trans"].timestamp_pb().ToSeconds()
            type_of_rice = d["type"]
            days_since_seeding = int((int(time.time()) - date_of_seed)/86400)

            days_since_trans = int((int(time.time()) - date_of_trans)/86400)
            
            users[doc.id] = {}
            users[doc.id]["lang"] = d["lang"]
            users[doc.id]["seed"] = days_since_seeding
            users[doc.id]["trans"] = days_since_trans
            users[doc.id]["type"] = type_of_rice
            if d["token"]:
                users[doc.id]["token"] = d["token"]
                
            loc = d["location"].split(" ")
            lat = float(loc[0])
            lon = float(loc[1])
            utc_timestamp = 1590537600 + 86400 * \
                (int((int(time.time())-1590537600)/86400)-1)
            api_key = "f436b14e3174387a43e778d21509d07c"
            data = [0, 0, 0]
            params = {'lat': lat, 'lon': lon,  'dt': utc_timestamp,
                      'appid': api_key, 'units': 'metric'}
            params2 = {'lat': lat, 'lon': lon,  'dt': utc_timestamp -
                       86400, 'appid': api_key, 'units': 'metric'}
            params3 = {'lat': lat, 'lon': lon,  'dt': utc_timestamp -
                       2*86400, 'appid': api_key, 'units': 'metric'}
            data[0] = requests.get(url="http://api.openweathermap.org/data/2.5/onecall/timemachine", params=params).json()
            data[1] = requests.get(url="http://api.openweathermap.org/data/2.5/onecall/timemachine", params=params2).json()
            data[2] = requests.get(url="http://api.openweathermap.org/data/2.5/onecall/timemachine", params=params3).json()

            print(data)
            
            avgD, avgN = calc_avg_temps(data)

            users[doc.id]["dTemp"] = avgD
            users[doc.id]["nTemp"] = avgN
            avgH = calc_avg_humid(data)

            users[doc.id]["humid"] = avgH
            avgC = calc_avg_cloud(data)
            avgDP = calc_avg_dew(data)
            users[doc.id]["dew"] = avgDP
            users[doc.id]["cloud"] = avgC
            avgR = calc_avg_rain(data)
           
            users[doc.id]["rain"] = avgR

        except Exception as e:
            pass

    return users


def batch_process(communicate):
    print("getting users")
    users = get_data(communicate.get_users())
    print("got users")
    notifications = {
        "hi": {
            "diseases": {
                "Leaf Blast": {
                    "tokens":[],
                    "body": [{
                        "message": "Leaf Blast"
                    }]
                },
                "BLB": {
                    "tokens":[],
                    "body": [{
                        "message": "BLB"
                    }]
                },
                "Brown Spot": {
                    "tokens":[],
                    "body": [{
                        "message": "Brown Spot"
                    }]
                },
                "Sheath Blight": {
                    "tokens":[],
                    "body": [{
                        "message": "Sheath Blight"
                    }]
                },
                "False Smut": {
                    "tokens":[],
                    "body": [{
                        "message": "False Smut"
                    }]
                },
                "Sheath Rot": {
                    "tokens":[],
                    "body": [{
                        "message": "Sheath Rot"
                    }]
                }
            },
            "treatments": {
                "0": {
                    "tokens":[],
                    "body": [{
                        "Step 1": "शुष्क नर्सरी के लिए बीज को 3 ग्राम कार्बेन्डाजिम प्रति किलोग्राम बीज से उपचारित करें",
                        "Step 2": "बीज को 1 ग्राम कार्बेन्डाजिम प्रति लीटर पानी में प्रति किलोग्राम बीज के हिसाब से भिगो दें",
                        "Step 3": "5 सेन्ट आकार की नर्सरी के लिए जुताई के दौरान नाइट्रोजेन, फॉस्फोरस, पोटाश प्रत्येक उर्वरक 1 किलोग्राम की दर से डालें।",
                        "Link": "https://youtu.be/v2Za4IMxs6s",
                        "Days": "0",
                        "message": "यह अत्यधिक अनुशंसा है कि आप हमारे द्वारा भेजे गए वीडियो को देखें। यह आपको नोटिफिकेशन सेक्शन में मिलेगा।"
                    }]
                },
                "14": {
                    "tokens":[],
                    "body": [{
                        "Step 1": "5 सेन्ट नर्सरी के लिए प्रति लीटर पानी में 2 ग्राम जिंक सल्फेट घोल का छिड़काव करें तथा",
                        "Step 2": "5 सेन्ट नर्सरी के लिए, 1 किलोग्राम नाइट्रोजेन उर्वरक डालें।",
                        "Link": "",
                        "Days": "14",
                        "message": "यह अत्यधिक अनुशंसा है कि आप हमारे द्वारा भेजे गए वीडियो को देखें। यह आपको नोटिफिकेशन सेक्शन में मिलेगा।"
                    }]
                },
                "20": {
                    "tokens":[],
                    "body": [{
                        "Step 1": "धान की शुरुआती अवस्था मॆ फफूॅद जनित रोगो की रोकथाम",
                        "Link": "https://www.youtube.com/watch?v=MUbXbTeSlmw",
                        "Days": "20",
                        "message": "यह अत्यधिक अनुशंसा है कि आप हमारे द्वारा भेजे गए वीडियो को देखें। यह आपको नोटिफिकेशन सेक्शन में मिलेगा।"
                    }]
                },
                "21": {
                    "tokens":[],
                    "body": [{
                        "Step 1": "5 सेन्ट नर्सरी के लिए 400 ग्राम कार्बोफ्यूरान 3 जी  दानेदार को एक किलोग्राम बालू (रेत) में मिलाएं एवं सुनिश्चित करें कि दवा डालने के समय पानी की पतली परत  नर्सरी मॆ बनी रखना चाहिए।",
                        "Link": "",
                        "Days": "21",
                        "message": "यह अत्यधिक अनुशंसा है कि आप हमारे द्वारा भेजे गए वीडियो को देखें। यह आपको नोटिफिकेशन सेक्शन में मिलेगा।"
                    }]
                },
                "26": {
                    "tokens":[],
                    "body": [{
                        "Step 1": "धान रोपाई के दौरान संकर धान के 33 कल्ले प्रति वर्ग मीटर और पारंपरिक किस्मो के लिए 44 कल्ले प्रति वर्ग मीटर की दर से संख्या को खेत में बनाए रखना है।",
                        "Link": "https://youtu.be/9LpSN1TWUUI",
                        "Days": "26",
                        "message": "यह अत्यधिक अनुशंसा है कि आप हमारे द्वारा भेजे गए वीडियो को देखें। यह आपको नोटिफिकेशन सेक्शन में मिलेगा।"
                    }]
                },
                "27": {
                    "tokens":[],
                    "body": [{
                        "Step 1": "धान की शुरुआती अवस्था मॆ फफूॅद जनित रोगो की रोकथाम",
                        "Link": "https://www.youtube.com/watch?v=MUbXbTeSlmw",
                        "Days": "27",
                        "message": "यह अत्यधिक अनुशंसा है कि आप हमारे द्वारा भेजे गए वीडियो को देखें। यह आपको नोटिफिकेशन सेक्शन में मिलेगा।"
                    }]
                },
                "34": {
                    "tokens":[],
                    "body": [{
                        "Step 1": "धान की शुरुआती अवस्था मॆ फफूॅद जनित रोगो की रोकथाम",
                        "Link": "https://www.youtube.com/watch?v=MUbXbTeSlmw",
                        "Days": "34",
                        "message": "यह अत्यधिक अनुशंसा है कि आप हमारे द्वारा भेजे गए वीडियो को देखें। यह आपको नोटिफिकेशन सेक्शन में मिलेगा।"
                    }]
                },
                "40": {
                    "tokens":[],
                    "body": [{
                        "Step 1": "जिंक सल्फेट हेक्टाहाइड्रेट का 25 किग्रा / हेक्टेयर अथवा 16 किग्रा / हेक्टेयर जिंक सल्फेट मोनोहाइड्रेट। ",
                        "Step 2": "0.5% जिंक सल्फेट  (25 ग्राम जिंक सल्फेट प्रति 10 लीटर पानी में) का छिङकाव करॆ।",
                        "Link": "https://youtu.be/tbsOs9POhVk",
                        "Days": "40",
                        "message": "यह अत्यधिक अनुशंसा है कि आप हमारे द्वारा भेजे गए वीडियो को देखें। यह आपको नोटिफिकेशन सेक्शन में मिलेगा।"
                    }]
                }
            }
        },
        "en": {
            "diseases": {
                "Leaf Blast": {
                    "tokens":[],
                    "body": [{
                        "message": "We believe that based on the weather, you are likely to have this disease in your crop: Leaf Blast"
                    }]
                },
                "BLB": {
                    "tokens":[],
                    "body": [{
                        "message": "We believe that based on the weather, you are likely to have this disease in your crop: BLB"
                    }]
                },
                "Brown Spot": {
                    "tokens":[],
                    "body": [{
                        "message": "We believe that based on the weather, you are likely to have this disease in your crop: Brown Spot"
                    }]
                },
                "Sheath Blight": {
                    "tokens":[],
                    "body": [{
                        "message": "We believe that based on the weather, you are likely to have this disease in your crop: Sheath Blight"
                    }]
                },
                "False Smut": {
                    "tokens":[],
                    "body": [{
                        "message": "We believe that based on the weather, you are likely to have this disease in your crop: False Smut"
                    }]
                },
                "Sheath Rot": {
                    "tokens":[],
                    "body": [{
                        "message": "We believe that based on the weather, you are likely to have this disease in your crop: Sheath Rot"
                    }]
                }
            },
            "treatments": {
                "0": {
                    "tokens":[],
                    "body": [{
                        "Step 1": "Treat Seeds with 3 gm Carbendazim per kg seed for dry Nursery",
                        "Step 2": "Soak Seed in 1 gm Carbendazim per litre water per Kg seed",
                        "Step 3": "For 5 cents of Nursery size, apply 1 kg each of  Nitrozen, Phosphorous, Potash fertilizer during ploughing",
                        "Link": "https://youtu.be/v2Za4IMxs6s",
                        "Days": "0",
                        "message": "Based on the current date, we highly reccomend that you perform treatment for your crop. Please go to the notifications section for more information."
                    }]
                },
                "14": {
                    "tokens":[],
                    "body": [{
                        "Step 1": "5 सेन्ट नर्सरी के लिए प्रति लीटर पानी में 2 ग्राम जिंक सल्फेट घोल का छिड़काव करें तथा",
                        "Step 2": "5 सेन्ट नर्सरी के लिए, 1 किलोग्राम नाइट्रोजेन उर्वरक डालें।",
                        "Link": "",
                        "Days": "14",
                        "message": "Based on the current date, we highly reccomend that you perform treatment for your crop. Please go to the notifications section for more information."
                    }]
                },
                "20": {
                    "tokens":[],
                    "body": [{
                        "Step 1": "Prevention of early fungal diseases in rice crop",
                        "Link": "https://www.youtube.com/watch?v=MUbXbTeSlmw",
                        "Days": "20",
                        "message": "Based on the current date, we highly reccomend that you perform treatment for your crop. Please go to the notifications section for more information."
                    }]
                },
                "21": {
                    "tokens":[],
                    "body": [{
                        "Step 1": "Apply 400 gm Carbofuran 3G granules mixed in a Kg of sand for 5 cent Nursey. Ensure thin layer of water is maintained at the time of application.",
                        "Link": "",
                        "Days": "21",
                        "message": "Based on the current date, we highly reccomend that you perform treatment for your crop. Please go to the notifications section for more information."
                    }]
                },
                "26": {
                    "tokens":[],
                    "body": [{
                        "Step 1": "Transplant seedlings maintaining a population of 33 hills per sq mt of land for hybrid rice and 44 hills per sq mt for traditional variety.",
                        "Link": "https://youtu.be/9LpSN1TWUUI",
                        "Days": "26",
                        "message": "Based on the current date, we highly reccomend that you perform treatment for your crop. Please go to the notifications section for more information."
                    }]
                },
                "27": {
                    "tokens":[],
                    "body": [{
                        "Step 1": "Prevention of early fungal diseases in rice crop",
                        "Link": "https://www.youtube.com/watch?v=MUbXbTeSlmw",
                        "Days": "27",
                        "message": "Based on the current date, we highly reccomend that you perform treatment for your crop. Please go to the notifications section for more information."
                    }]
                },
                "34": {
                    "tokens":[],
                    "body": [{
                        "Step 1": "Prevention of early fungal diseases in rice crop",
                        "Link": "https://www.youtube.com/watch?v=MUbXbTeSlmw",
                        "Days": "34",
                        "message": "Based on the current date, we highly reccomend that you perform treatment for your crop. Please go to the notifications section for more information."
                    }]
                },
                "40": {
                    "tokens":[],
                    "body": [{
                        "Step 1": "25 kg/Hectare of Zinc Sulphate HectaHydrate or 16 Kg/ Hectare Zinc Sulphate Monohydrate.",
                        "Step 2": "Spray of 0.5% Zinc Sulphate (25 gm Zinc Sulphate in 10 lit of water)",
                        "Link": "https://youtu.be/tbsOs9POhVk",
                        "Days": "40",
                        "message": "Based on the current date, we highly reccomend that you perform treatment for your crop. Please go to the notifications section for more information."
                    }]
                }
            }
        }
    }

    print(len(users))
    for i in users:
        try:
            user = users[i]
            currentLang = user["lang"]
            currentToken = user["token"]
            # diseases = get_diseases(user)
            treatment = str(user["seed"])

            # for disease in diseases:
            #     notifications[currentLang]["diseases"][disease]["tokens"].append(currentToken)
            #     communicate.add_daily_disease(i, notifications[currentLang]["diseases"][treatment]["body"], 2)

            notifications[currentLang]["treatments"][treatment]["tokens"].append(currentToken)
            communicate.add_daily_disease(i, notifications[currentLang]["treatments"][treatment]["body"], 1)
        except Exception as e:
            print(e)

    print(notifications)

    try:
        for lang in notifications:
            for types in notifications[lang]:
                for name in notifications[lang][types]:
                    notification = notifications[lang][types][name]
                    worked = communicate.send_notifications(notification["tokens"], "Disease Prediction", str(notification["body"][0]["message"]))
                    print(len(notification["tokens"]))
                    print(worked)
    except Exception as e2:
        print(e2)

# def get_notifs(data):
#     treatments = []
#     if data["lang"] == "hi":
#         if(data["seed"] == 0):
#             treatments.append({"Step 1": "शुष्क नर्सरी के लिए बीज को 3 ग्राम कार्बेन्डाजिम प्रति किलोग्राम बीज से उपचारित करें",
#                                "Step 2": "बीज को 1 ग्राम कार्बेन्डाजिम प्रति लीटर पानी में प्रति किलोग्राम बीज के हिसाब से भिगो दें",
#                                "Step 3": "5 सेन्ट आकार की नर्सरी के लिए जुताई के दौरान नाइट्रोजेन, फॉस्फोरस, पोटाश प्रत्येक उर्वरक 1 किलोग्राम की दर से डालें।", "Link": "https://youtu.be/v2Za4IMxs6s", "Days": "0"})
#         elif(data["seed"] == 14):
#             treatments.append({"Step 1": "5 सेन्ट नर्सरी के लिए प्रति लीटर पानी में 2 ग्राम जिंक सल्फेट घोल का छिड़काव करें तथा",
#                                "Step 2": "5 सेन्ट नर्सरी के लिए, 1 किलोग्राम नाइट्रोजेन उर्वरक डालें।", "Link": "", "Days": "14"})
#         elif (data["seed"] == 20):
#             treatments.append({"Step 1": "धान की शुरुआती अवस्था मॆ फफूॅद जनित रोगो की रोकथाम",
#                                "Link": "https://www.youtube.com/watch?v=MUbXbTeSlmw", "Days": "20"})
#         elif(data["seed"] == 21):
#             treatments.append(
#                 {"Step 1": "5 सेन्ट नर्सरी के लिए 400 ग्राम कार्बोफ्यूरान 3 जी  दानेदार को एक किलोग्राम बालू (रेत) में मिलाएं एवं सुनिश्चित करें कि दवा डालने के समय पानी की पतली परत  नर्सरी मॆ बनी रखना चाहिए।", "Link": "", "Days": "21"})
#         elif(data["seed"] == 26):
#             treatments.append(
#                 {"Step 1": "धान रोपाई के दौरान संकर धान के 33 कल्ले प्रति वर्ग मीटर और पारंपरिक किस्मो के लिए 44 कल्ले प्रति वर्ग मीटर की दर से संख्या को खेत में बनाए रखना है।", "Link": "https://youtu.be/9LpSN1TWUUI",  "Days": "26"})
#         elif(data["seed"] == 27):
#             treatments.append({"Step 1": "धान की शुरुआती अवस्था मॆ फफूॅद जनित रोगो की रोकथाम",
#                                "Link": "https://www.youtube.com/watch?v=MUbXbTeSlmw",  "Days": "27"})
#         elif(data["seed"] == 34):
#             treatments.append({"Step 1": "धान की शुरुआती अवस्था मॆ फफूॅद जनित रोगो की रोकथाम",
#                                "Link": "https://www.youtube.com/watch?v=MUbXbTeSlmw", "Days": "34"})
#         elif(data["seed"] == 40):
#             treatments.append({"Step 1": "जिंक सल्फेट हेक्टाहाइड्रेट का 25 किग्रा / हेक्टेयर अथवा 16 किग्रा / हेक्टेयर जिंक सल्फेट मोनोहाइड्रेट। ",
#                                "Step 2": "0.5% जिंक सल्फेट  (25 ग्राम जिंक सल्फेट प्रति 10 लीटर पानी में) का छिङकाव करॆ।", "Link": "https://youtu.be/tbsOs9POhVk", "Days": "40"})
#     else:
#         if(data["seed"] == 0):
#             treatments.append({"Step 1": "Treat Seeds with 3 gm Carbendazim per kg seed for dry Nursery",
#                                "Step 2": "Soak Seed in 1 gm Carbendazim per litre water per Kg seed",
#                                "Step 3": "For 5 cents of Nursery size, apply 1 kg each of  Nitrozen, Phosphorous, Potash fertilizer during ploughing", "Link": "https://youtu.be/v2Za4IMxs6s", "Days": "0"})
#         elif(data["seed"] == 14):
#             treatments.append({"Step 1": "Spray 2 gm Zinc Sulphate Solution per Lt water for 5 cent Nursery",
#                                "Step 2": "Apply 1 Kg Nitrozen fertilizer for 5 cent nursery", "Link": ""
#                                , "Days": "14"})
#         elif(data["seed"] == 20):
#             treatments.append({"Step 1": "Prevention of early fungal diseases in rice crop",
#                                "Link": "https://www.youtube.com/watch?v=MUbXbTeSlmw"
#                                , "Days": "20"})
#         elif(data["seed"] == 21):
#             treatments.append(
#                 {"Step 1": "Apply 400 gm Carbofuran 3G granules mixed in a Kg of sand for 5 cent Nursey. Ensure thin layer of water is maintained at the time of application.", "Link": ""
#                 , "Days": "21"})
#         elif(data["seed"] == 26):
#             treatments.append(
#                 {"Step 1": "Transplant seedlings maintaining a population of 33 hills per sq mt of land for hybrid rice and 44 hills per sq mt for traditional variety.", "Link": "https://youtu.be/9LpSN1TWUUI"
#                 , "Days": "26"})
#         elif(data["seed"] == 27):
#             treatments.append({"Step 1": "Prevention of early fungal diseases in rice crop",
#                                "Link": "https://www.youtube.com/watch?v=MUbXbTeSlmw"
#                                , "Days": "27"})
#         elif data["seed"] == 34:
#             treatments.append({"Step 1": "Prevention of early fungal diseases in rice crop",
#                                "Link": "https://www.youtube.com/watch?v=MUbXbTeSlmw"
#                                , "Days": "34"})
#         elif(data["seed"] == 40):
#             treatments.append({"Step 1": "25 kg/Hectare of Zinc Sulphate HectaHydrate or 16 Kg/ Hectare Zinc Sulphate Monohydrate.",
#                                "Step 2": "Spray of 0.5% Zinc Sulphate (25 gm Zinc Sulphate in 10 lit of water)", "Link": "https://youtu.be/tbsOs9POhVk"
#                                , "Days": "40"})
#     return treatments


def get_diseases(data):
    dis = []
    if blast(data):
        dis.append("Leaf Blast")
    if bac_blight(data):
        dis.append("BLB")
    if brown_spot(data):
        dis.append("Brown Spot")
    if she_blight(data):
        dis.append("Sheath Blight")
    if smut(data):
        dis.append("False Smut")
    if sheath_rot(data):
        dis.append("Sheath Rot")

    return dis


def sheath_rot(data):
    if calc_stage(data["type"], data["seed"]) == 2 and data["humid"] > 90 and data["dTemp"] > 24 and data["dTemp"] < 29 and data["nTemp"] > 17 and data["nTemp"] < 22:
        return True
    else:
        return False


def blast(data):
    if data["seed"] > 29 and calc_stage(data["type"], data["seed"]) != 3 and classify_rain(data["rain"]) > 0 and data["cloud"] >= 75 and data["humid"] > 90 and data["dTemp"] > 24 and data["dTemp"] < 29 and data["nTemp"] < 22 and data["nTemp"] > 17:
        return True
    else:
        return False


def bac_blight(data):
    if data["seed"] > 29 and calc_stage(data["type"], data["seed"]) != 3 and data["cloud"] >= 90 and classify_rain(data["rain"]) == 2 and data["humid"] > 70 and (data["dTemp"] > 29 and data["dTemp"] < 35) and data["nTemp"] > 17 and data["nTemp"] < 22:
        return True
    else:
        return False


def brown_spot(data):
    if data["seed"] > 29 and calc_stage(data["type"], data["seed"]) != 3 and data["humid"] > 92 and (data["dTemp"] > 24 and data["dTemp"] < 31) and data["nTemp"] > 17 and data["nTemp"] < 22:
        return True
    else:
        return False


def she_blight(data):
    if data["seed"] > 29 and calc_stage(data["type"], data["seed"]) != 3 and data["humid"] > 85 and (data["dTemp"] > 19 and data["dTemp"] < 25) and data["nTemp"] > 17 and data["nTemp"] < 22:
        return True
    else:
        return False


def smut(data):
    if calc_stage(data["type"], data["seed"]) > 1 and data["humid"] > 92 and classify_rain(data["rain"]) > 0 and (data["dTemp"] > 19 and data["dTemp"] < 26) and data["nTemp"] > 17 and data["nTemp"] < 22:
        return True
    else:
        return False


def calc_stage(tpe, seed):
    if tpe == 1:
        if seed > 81:
            return 3
        elif seed > 45:
            return 2
        else:
            return 1
    elif tpe == 2:
        if seed > 101:
            return 3
        elif seed > 65:
            return 2
        else:
            return 1
    else:
        if seed > 121:
            return 3
        elif seed > 85:
            return 2
        else:
            return 1


def classify_rain(rate):
    if rate == 0:
        return 0
    elif rate < 2.5:
        return 1
    else:
        return 2


def calc_avg_rain(data):
    total = 0
    count = 0
    for k in data:
        for i in k["hourly"]:
            try:
                if i["rain"] != 0:
                    total += i["rain"]
                    count += 1
            except Exception as e:
                total += 0

    if count == 0:
        return 0
    return round(total/count)


def calc_avg_dew(data):
    count = 0
    total = 0
    for k in data:
        for i in k["hourly"]:
            count += 1
            total += i["dew_point"]
    return round(total/count)


def calc_avg_cloud(data):
    count = 0
    total = 0
    for k in data:
        for i in k["hourly"]:
            if(i["clouds"] != 0):
                count += 1
                total += i["clouds"]
    return round(total/count)


def calc_avg_humid(data):
    count = 0
    total = 0
    for k in data:
        for i in k["hourly"]:
            count += 1
            total += i["humidity"]
    return round(total/count)


def calc_avg_temps(data):
    maxTotal = 0
    minTotal = 0
    for k in data:
        maxVal = -1
        minVal = 100
        for i in k["hourly"]:
            maxVal = max(i["temp"], maxVal)
            minVal = min(i["temp"], minVal)

        maxTotal += maxVal
        minTotal += minVal
    return round(maxTotal/3), round(minTotal/3)