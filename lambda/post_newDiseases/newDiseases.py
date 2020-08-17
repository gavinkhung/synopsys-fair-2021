import json

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'body': json.dumps({
            "hi" : {
                "Leaf Blast": {
                    "Disease": "लीफ ब्लास्ट (झौंका)",
                    "Step 1": " ट्राईसाइक्लाज़ोल @ 6ग्राम / 10 ली0  पानी की दर से छिड़काव करे।",
                    "Step 2": "यूरिया का प्रयोग बिलकुल न करें, यूरिया तभी डालॆ जब लीफ कलर कार्ड सुझाव दे  वह भी दवा डालने के 7 दिनों के बाद। ",
                    "Step 3": "फसल अवशेष नष्ट करें",
                    "Link": "https://youtu.be/QSSAr56AdD8",
                    "Image": "https://i1.wp.com/agfax.com/wp-content/uploads/rice-blast-leaf-lesions-lsu.jpg?fit=600%2C400&ssl=1"

                },
                "BLB": {
                    "Disease": "बैक्टीरियल लीफ ब्लाइट",
                    "Step 1": "स्ट्रेप्टोमाइसिन सल्फेट एवं टेट्रासाइक्लिन को (साथ मिलाकर) 300 ग्राम + कॉपर ऑक्सीक्लोराइड 1.25 किग्रा / हेक्टेयर की दर से छिड़काव करें। यदि आवश्यक हो तो 15 दिन बाद फिर दवा छिङकॆ।",
                    "Step 2": "गब्भा अवस्था के पहले यदि रोग हो, तो खेत से पानी निकाल दें",
                    "Step 3": "3-4 दिनों के लिए खेत को सूखने दें",
                    "Link": "https://youtu.be/C44FxCu7ubo",
                    "Image": "https://m.farms.com/Portals/0/bacterial-leaf-blight-300-1_1.png"
                },
                "False Smut": {
                    "Disease": " आभाषी कंड (कंडवा या हरदी)",
                    "Step 1": "7 दिनों के अंतराल पर हेक्साकोनाज़ोल @ 1.0 मिली / लीटर पानी का 2 बार छिङकाव करें",
                    "Step 2": "",
                    "Step 3": "",
                    "Link": "https://youtu.be/zxbcXWJ6cTA",
                    "Image": "https://www.lsuagcenter.com/~/media/system/9/4/a/e/94ae4909bab82f9b5def7eabc3bb6983/falsesmut4.jpg"
                },
                "Brown Spot": {
                    "Disease": " भूरा धब्बा ",
                    "Step 1": "पोटाश का छिङकाव  करॆ और  प्रोपिकोनाज़ोल @ 1.0 ग्राम या क्लोरोथालोनिल@2.0 ग्राम प्रति लीटर पानी में डालें या  ट्राइसाइक्लाजोल 18% + मानोकोजेब 62% WP 1.0 कि ग्रा  प्रति हेक्टेयर डालॆ,  और 10-12 दिनों के बाद दोहराएं यदि लक्षण बने रहें",
                    "Step 2": "",
                    "Step 3": "",
                    "Link": "https://youtu.be/AxFCqZFwDQo",
                    "Image": "https://www.indogulfbioag.com/Rice-Protect-Kits/images/brown-spot-big.jpg"
                },
                "Sheath Blight": {
                    "Disease": "शीथ ब्लाइट या पर्ण अंगमारी",
                    "Step 1": "यूरिया का प्रयोग बिलकुल न करें, यूरिया तभी डालॆ जब लीफ कलर कार्ड सुझाव दे  वह भी दवा डालने के 7 दिनों के बाद",
                    "Step 2": "कार्बेन्डाजिम @ 1.0 ग्राम या प्रोपिकोनाजोल @ 1.0 मिली या हेक्साकोनाजोल @ 1.0 मिली प्रति लीटर पर्ण स्प्रे के रूप में। अगर लक्षण बने रहें तो 10-15 दिन बाद दोहराएं",
                    "Step 3": "",
                    "Link": "https://youtu.be/gLPX_2QcdqM",
                    "Image": "https://www.apsnet.org/edcenter/disandpath/fungalasco/pdlessons/Article%20Images/RiceSheathFig5.jpg"
                },
                "ZnDf": {
                    "Disease": "खैरा",
                    "Step 1": "0.5% जिंक सल्फेट का छिङकाव (10 लीटर पानी में 25 ग्राम जिंक सल्फेट)। जिंक सल्फेट हेक्टाहाइड्रेट के 25 किग्रा / हेक्टेयर या 16 किलोग्राम / हेक्टेयर जिंक सल्फेट मोनोहाइड्रेट का प्रयोग करें।",
                    "Step 2": "0.5% जिंक सल्फेट का छिङकाव (10 लीटर पानी में 25 ग्राम जिंक सल्फेट)",
                    "Step 3": "",
                    "Link": "https://youtu.be/tbsOs9POhVk",
                    "Image": "https://lariceman.files.wordpress.com/2010/06/bronzing-6-10-2.jpg"
                },
                "Sheath Rot": {
                    "Disease": "शीथ रोट",
                    "Step 1": "कार्बेन्डाजिम @ 250 ग्राम या प्रोपिकोनाजोल @ 2.0 मिली या क्लोरोथैलोनिल @ 1.0 किलोग्राम या इडिफेनफोस प्रति लीटर  प्रति हेक्टेयर का छिङकाव करॆ। अगर लक्षण बने रहें तो 10-15 दिन बाद दोहराएं",
                    "Step 2": "",
                    "Step 3": "",
                    "Link": "https://www.youtube.com/watch?v=Dqv1jAGLViU",
                    "Image": "https://www.gardeningknowhow.com/wp-content/uploads/2019/07/sheath-rot.jpg"
                },
                "PaddyField": {
                    "Disease" : "कृपया रोगी पौधे की पास से फोटो लॆ।",
                    "Step 1" : "", 
                    "Step 2": "", 
                    "Step 3": "",
                    "Link" : "",
                    "Image": "",
                },
                "This is not rice": {
                    "Disease": "कृपया धान की एक फोटो भेजें!",
                    "Step 1": "",
                    "Step 2": "",
                    "Step 3": "",
                    "Link": ""
                },
                "Image is unclear. Please try again": {
                    "Disease": "छवि अस्पष्ट है। कृपया पुनः प्रयास करें"
                },
                "Healthy": {
                    "Disease": "स्वस्थ धान का पौधा!"
                }
            },
            "en": {
                "Leaf Blast": {
                    "Disease": "Leaf Blast",
                    "Step 1": "Apply Tricyclazole @ 6gm/10L water",
                    "Step 2": "Do not apply urea. Apply after 7 days of blast treatment, only if LCC recommends",
                    "Step 3": "Destroy debris post harvest",
                    "Link": "https://youtu.be/QSSAr56AdD8",
                    "Image": "https://i1.wp.com/agfax.com/wp-content/uploads/rice-blast-leaf-lesions-lsu.jpg?fit=600%2C400&ssl=1"
                },
                "BLB": {
                    "Disease": "Bacterial Leaf Blight",
                    "Step 1": "Spray Streptomycin sulphate + Tetracycline combination 300 g + Copper oxychloride 1.25kg/ha. If necessary repeat 15 days later.",
                    "Step 2": "Drain the field if in vegetative stage",
                    "Step 3": "Leave the field dry for 3-4 days",
                    "Link": "https://youtu.be/C44FxCu7ubo",
                    "Image": "https://m.farms.com/Portals/0/bacterial-leaf-blight-300-1_1.png"
                },
                "False Smut": {
                    "Disease": "FalseSmut",
                    "Step 1": "2 times spray of hexaconazole @ 1.0ml/ litre water at 7 days interval",
                    "Step 2": "",
                    "Step 3": "",
                    "Link": "https://youtu.be/zxbcXWJ6cTA",
                    "Image": "https://www.lsuagcenter.com/~/media/system/9/4/a/e/94ae4909bab82f9b5def7eabc3bb6983/falsesmut4.jpg"
                },
                "Brown Spot": {
                    "Disease": "Brown Spot",
                    "Step 1": "Apply PotashSpray Propiconazole@1.0 gm or Chlorothalonil@2.0 gm per litre of water or Tricyclazole 18% + Manocozeb 62% WP 1000- 1250 gm per Hectare and repeat after 10-12 days if symptoms persist",
                    "Step 2": "",
                    "Step 3": "",
                    "Link": "https://youtu.be/AxFCqZFwDQo",
                    "Image": "https://www.indogulfbioag.com/Rice-Protect-Kits/images/brown-spot-big.jpg"
                },
                "Sheath Blight": {
                    "Disease": "Sheath Blight",
                    "Step 1": "Do not apply urea after detection till recommended by LCC",
                    "Step 2": "Carbendazim @ 1.0 gm or Propiconazole @ 1.0 ml or Hexaconazole @ 1.0 ml per itre as foliar spray. Repeat after 15 days",
                    "Step 3": "",
                    "Link": "https://youtu.be/gLPX_2QcdqM",
                    "Image": "https://www.apsnet.org/edcenter/disandpath/fungalasco/pdlessons/Article%20Images/RiceSheathFig5.jpg"
                },
                "ZnDf": {
                    "Disease": "Khaira",
                    "Step 1": "25 kg/Hectare of Zinc Sulphate HectaHydrate or 16 Kg/ Hectare Zinc Sulphate Monohydrate.",
                    "Step 2": "Spray of 0.5% Zinc Sulphate (25 gm Zinc Sulphate in 10 lit of water)",
                    "Step 3": "",
                    "Link": "https://youtu.be/tbsOs9POhVk",
                    "Image":"https://lariceman.files.wordpress.com/2010/06/bronzing-6-10-2.jpg"
                },
                "Sheath Rot": {
                    "Disease": "Sheath Rot",
                    "Step 1": "Sprinkle carbendazim @ 250 g or propiconazole @ 2.0 ml or chlorothalonil @ 1.0 kg or idiphenphos   per liter per hectare. Repeat after 10-15 days if symptoms persist.",
                    "Step 2": "",
                    "Step 3": "",
                    "Link": "https://www.youtube.com/watch?v=Dqv1jAGLViU",
                    "Image": "https://www.gardeningknowhow.com/wp-content/uploads/2019/07/sheath-rot.jpg"   
                },
                "PaddyField": {
                    "Disease" : "Please take a close-up photo of the affected plant part",
                    "Step 1" : "", 
                    "Step 2": "", 
                    "Step 3": "",
                    "Link" : "",
                    "Image": "",
                },
                "This is not rice": {
                    "Disease": "Please send an image of Rice!",
                    "Step 1": "",
                    "Step 2": "",
                    "Step 3": "",
                    "Link": ""
                },
                "Image is unclear. Please try again": {
                    "Disease": "Image is unclear. Please try again"
                },
                "Healthy": {
                    "Disease": "Healthy Rice Plant!"
                }
            }
        })
    }