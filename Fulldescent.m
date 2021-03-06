%Setup paramaters
%All units are SI (NO FEET!)
samples = 1e6; %number of diecreet time steps
duration = 150; %(s) duration of the simulation, needs a abtter way to find this time
timeInterval = duration/samples;
last = samples;

apogee = 1310; %(m) Divide by  3.281 for feet
%Select either to have the chute deploy at either a certain height or
%time after apogee, if using height, set time to duration+1, if using
%time, set height to 0
mainDeployTime = duration+1;
mainDeployHeight = 100;
drougeDeployTime = 3;
drougeDeployHeight = 0;

%Drag data for the rocket, drouge and main chute
%Data from OpenRocket
rocketCd = 0.44;
rocketA = 9.67e-3;
mainCd = 0.97;
mainA = 1.7;
drougeCd = 1.5;
drougeA = .289;
mass = 3;

%Enviromental data
g = -9.8;
rho = 1.225;

%%Build data tablet = 1
t = 1;
v = 3;
a = 2;
alt = 4;
f = 5;
d=6;
data = zeros(samples,7);
data(:,t)=linspace(0,duration,samples);
data(1,2:4) = [g 0 apogee];


for iteration = 2:samples
    time = data(iteration,t);
    vLast = data(iteration-1,v);
    aLast = data(iteration-1,a);
    altLast = data(iteration-1,alt);
    mainFlag = mainDeployTime<time | mainDeployHeight>altLast;
    drougeFlag = drougeDeployTime<time | drougeDeployHeight>altLast;
    vel = data(iteration-1,a)*timeInterval+vLast;
    drag = 0.5*vel^2*rho*(rocketA*rocketCd+mainCd*mainA*mainFlag+drougeCd*drougeA*drougeFlag);
    force = drag+mass*g;
    accel = force/mass;
    alti=altLast+vel*timeInterval;
    data(iteration,2:6)=[accel vel alti force drag];
    if alti<=0
        last = iteration;
        data(iteration:end,:)=0;
        break
    end
end
data=data(1:last-1,:);

%Report the data
fprintf("Total descent time: %.1f s\n", last*timeInterval)
fprintf("Max Acceleration: %.2f m s^-2, %2f g\n", max(data(:,2)),max(data(:,2))/g)
fprintf("Landing Speed: %.2f m s^-1", abs(data(end,3)))
%graph the data
tiledlayout(2,1)
nexttile
plot(data(2:end,1),data(2:end,v))
title("Velocity")
ylabel("Velocity (m s^2)")
xlabel("Time (s)")
nexttile
plot(data(2:end,1),data(2:end,a))
title("Acceleration")
ylabel("Acceleration (m s^2)")
xlabel("Time (s)")


