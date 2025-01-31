@echo off

rem add all update files into local git repo
git add .

rem commit all changes and put comment
git commit -m "update"

rem push all changes into github repo
git push

docker image rm localhost:5000/actone10:latest -f

docker build . -t localhost:5000/actone10:latest

docker push localhost:5000/actone10:latest

rem delete all image with name <none>
docker rmi $(docker images -f "dangling=true" -q)

rem delete pod with label kum-app
kubectl delete pod -l app=actone10-deployment

timeout 5
rem open pod log
kubectl logs -f -l app=actone10-deployment
rem kubectl exec actone10-deployment-566bffdd7b-n9wmc -c actone10-container -i -t -- bash