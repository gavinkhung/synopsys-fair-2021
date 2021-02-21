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
    if data["seed"] > 29 and calc_stage(data["type"], data["seed"]) != 3  and  data["humid"] > 90 and data["dTemp"] > 24 and data["dTemp"] < 29 and data["nTemp"] < 22 and data["nTemp"] > 17:
        return True
    else:
        return False


def bac_blight(data):
    if data["seed"] > 29 and calc_stage(data["type"], data["seed"]) != 3 and data["humid"] > 70 and (data["dTemp"] > 29 and data["dTemp"] < 35) and data["nTemp"] > 17 and data["nTemp"] < 22:
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
    if calc_stage(data["type"], data["seed"]) > 1 and data["humid"] > 92 and (data["dTemp"] > 19 and data["dTemp"] < 26) and data["nTemp"] > 17 and data["nTemp"] < 22:
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


