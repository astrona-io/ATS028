import json,subprocess

def run(*args):
    return subprocess.run(["kubectl",*args],check=True,capture_output=True,text=True,timeout=15).stdout.strip()

def get(kind,name):
    return json.loads(run("-n","starfleet","get",kind,name,"-o","json"))

def can(verb,resource,namespace,identity):
    result=subprocess.run(["kubectl","auth","can-i",verb,resource,"-n",namespace,identity],capture_output=True,text=True,timeout=15)
    assert result.returncode in (0,1) and result.stdout.strip() in ("yes","no"), "Authorization check failed"
    return result.returncode==0 and result.stdout.strip()=="yes"

settings=get("configmap","probe-settings")
assert settings.get("data",{}).get("greeting")=="welcome", "Restore the required key"
deployment=get("deployment","probe"); spec=deployment["spec"]; status=deployment.get("status",{})
assert spec["replicas"]==2 and status.get("readyReplicas",0)==2 and status.get("availableReplicas",0)==2, "Keep two healthy replicas"
container=spec["template"]["spec"]["containers"][0]
assert container["image"]=="docker.io/library/python:3.13-alpine" and container["command"]==["python","/app/server.py"], "Preserve the application"
env={entry["name"]:entry for entry in container.get("env",[])}
assert env["GREETING"]=={"name":"GREETING","valueFrom":{"configMapKeyRef":{"name":"probe-settings","key":"greeting"}}}, "Preserve the required reference"
response=run("-n","starfleet","exec","shuttle","--","wget","-q","-T","3","-O-","http://probe/")
assert "version=v1 host=probe-" in response and "greeting=welcome" in response, "Verify consumed configuration"
# Check declared baseline fields while allowing Kubernetes defaulted fields.
from pathlib import Path
baseline=json.loads((Path(__file__).resolve().parent/"deployment-contract.json").read_text())
def contains(actual,expected):
    if isinstance(expected,dict):
        return isinstance(actual,dict) and all(key in actual and contains(actual[key],value) for key,value in expected.items())
    if isinstance(expected,list):
        return isinstance(actual,list) and len(actual)==len(expected) and all(contains(left,right) for left,right in zip(actual,expected))
    return actual==expected
assert contains(spec,baseline), "Preserve the Deployment contract"
print("Required resource contract and behavior verified")
