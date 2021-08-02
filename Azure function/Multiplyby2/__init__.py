import json
from pulp import *
from datetime import datetime

import logging
import azure.functions as func


def main(req: func.HttpRequest) -> func.HttpResponse:
    logging.info('Python HTTP trigger function processed a request.')

    #data is now a dict because the json body has been decoded
    data = req.get_json()
    supplylines = data["supplylines"]
    demandlines = data["demandlines"]
    source = []
    destination = []
    supply = {}
    demand = {}
    cost = {}
    costl = {}
    costl2 = {}
    solution = {}
    bodysolution = {}
    solutions = []

    for supplyline in supplylines:
        source.append(supplyline["id"])
        supply[supplyline["id"]] = supplyline["quantity"]
        for demandline in demandlines:
            if (datetime.fromisoformat(supplyline["receiptdate"]) - datetime.fromisoformat(demandline["deliverydate"])).days > 0:
                costl[demandline["id"]] = 99999999999
            else:
                costl[demandline["id"]] = (datetime.fromisoformat(supplyline["receiptdate"]) - datetime.fromisoformat(demandline["deliverydate"])).days
        costl2 = costl.copy()
        cost[supplyline["id"]] = costl2

    #print(cost)

    for demandline in demandlines:
        destination.append(demandline["id"])
        demand[demandline["id"]] = demandline["quantity"]

    prob = LpProblem('Reservations', LpMinimize)
    possiblereservations = [(i, j) for i in source for j in destination]
    quantity = LpVariable.dicts('reservationquantity', (source, destination), 0)
    prob += lpSum(quantity[i][j]*cost[i][j] for (i, j) in possiblereservations)
    for j in destination:
        prob += lpSum(quantity[i][j] for i in source) == demand[j]

    for i in source:
        prob += lpSum(quantity[i][j] for j in destination) <= supply[i]

    prob.solve()
    #print("Status:", LpStatus[prob.status])

    if LpStatus[prob.status] == "Optimal":
        for v in prob.variables():
            if v.varValue > 0:
                s = v.name;
                s = s.split('_')
                solution["id"] = v.name;
                solution["supplyline"] = s[1];
                solution["demandline"] = s[2];
                solution["quantity"] = v.varValue;
                solution2 = solution.copy();
                solutions.append(solution2)
        bodysolution["solution"] = solutions
        #print('Optimal solution:', value(prob.objective))
    else:
        bodysolution["solution"] = "no optimal solution"

    #return func.HttpResponse(json.dumps(data), headers={"content-type": "application/json"})
    return func.HttpResponse(json.dumps(bodysolution), headers={"content-type": "application/json"})
