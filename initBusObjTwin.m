clearvars; close all; clc;

busFile = 'busVarsTwin.mat';

%% === twin->ctrl information bus (signals for eCAT transfer) =============
elCnt = 1;
twin2ctrl(elCnt) = Simulink.BusElement;
twin2ctrl(elCnt).Name = 'Vel_Aft';
twin2ctrl(elCnt).Dimensions = 1;
twin2ctrl(elCnt).DimensionsMode = 'Fixed';
twin2ctrl(elCnt).DataType = 'double';
twin2ctrl(elCnt).SampleTime = -1;
twin2ctrl(elCnt).Complexity = 'real';

elCnt = elCnt + 1;
twin2ctrl(elCnt) = Simulink.BusElement;
twin2ctrl(elCnt).Name = 'Vel_Bow';
twin2ctrl(elCnt).Dimensions = 1;
twin2ctrl(elCnt).DimensionsMode = 'Fixed';
twin2ctrl(elCnt).DataType = 'double';
twin2ctrl(elCnt).SampleTime = -1;
twin2ctrl(elCnt).Complexity = 'real';

% =========================================================================

%% === ctrl->twin information bus (signals from eCAT transfer) =============
elCnt = 1;
ctrl2twin(elCnt) = Simulink.BusElement;
ctrl2twin(elCnt).Name = 'Cur_Aft';
ctrl2twin(elCnt).Dimensions = 1;
ctrl2twin(elCnt).DimensionsMode = 'Fixed';
ctrl2twin(elCnt).DataType = 'double';
ctrl2twin(elCnt).SampleTime = -1;
ctrl2twin(elCnt).Complexity = 'real';

elCnt = elCnt + 1;
ctrl2twin(elCnt) = Simulink.BusElement;
ctrl2twin(elCnt).Name = 'Cur_Bow';
ctrl2twin(elCnt).Dimensions = 1;
ctrl2twin(elCnt).DimensionsMode = 'Fixed';
ctrl2twin(elCnt).DataType = 'double';
ctrl2twin(elCnt).SampleTime = -1;
ctrl2twin(elCnt).Complexity = 'real';

% =========================================================================
%% === twin torque information bus  =============
elCnt = 1;
torque(elCnt) = Simulink.BusElement;
torque(elCnt).Name = 'Tqe_Aft';
torque(elCnt).Dimensions = 1;
torque(elCnt).DimensionsMode = 'Fixed';
torque(elCnt).DataType = 'double';
torque(elCnt).SampleTime = -1;
torque(elCnt).Complexity = 'real';

elCnt = elCnt + 1;
torque(elCnt) = Simulink.BusElement;
torque(elCnt).Name = 'Tqe_Bow';
torque(elCnt).Dimensions = 1;
torque(elCnt).DimensionsMode = 'Fixed';
torque(elCnt).DataType = 'double';
torque(elCnt).SampleTime = -1;
torque(elCnt).Complexity = 'real';

% =========================================================================

%% === EtherCAT status bus ================================================
elCnt = 1;
eCAT(elCnt) = Simulink.BusElement;
eCAT(elCnt).Name = 'eCAT_Err';
eCAT(elCnt).Dimensions = 1;
eCAT(elCnt).DimensionsMode = 'Fixed';
eCAT(elCnt).DataType = 'int32';
eCAT(elCnt).SampleTime = -1;
eCAT(elCnt).Complexity = 'real';

elCnt = elCnt + 1;
eCAT(elCnt) = Simulink.BusElement;
eCAT(elCnt).Name = 'eCAT_LastErr';
eCAT(elCnt).Dimensions = 1;
eCAT(elCnt).DimensionsMode = 'Fixed';
eCAT(elCnt).DataType = 'int32';
eCAT(elCnt).SampleTime = -1;
eCAT(elCnt).Complexity = 'real';

elCnt = elCnt + 1;
eCAT(elCnt) = Simulink.BusElement;
eCAT(elCnt).Name = 'eCAT_State';
eCAT(elCnt).Dimensions = 1;
eCAT(elCnt).DimensionsMode = 'Fixed';
eCAT(elCnt).DataType = 'int32';
eCAT(elCnt).SampleTime = -1;
eCAT(elCnt).Complexity = 'real';

elCnt = elCnt + 1;
eCAT(elCnt) = Simulink.BusElement;
eCAT(elCnt).Name = 'eCAT_DC_Err';
eCAT(elCnt).Dimensions = 1;
eCAT(elCnt).DimensionsMode = 'Fixed';
eCAT(elCnt).DataType = 'int32';
eCAT(elCnt).SampleTime = -1;
eCAT(elCnt).Complexity = 'real';

elCnt = elCnt + 1;
eCAT(elCnt) = Simulink.BusElement;
eCAT(elCnt).Name = 'eCAT_MN_ClkDiff';
eCAT(elCnt).Dimensions = 1;
eCAT(elCnt).DimensionsMode = 'Fixed';
eCAT(elCnt).DataType = 'int32';
eCAT(elCnt).SampleTime = -1;
eCAT(elCnt).Complexity = 'real';

elCnt = elCnt + 1;
eCAT(elCnt) = Simulink.BusElement;
eCAT(elCnt).Name = 'eCAT_DCInit';
eCAT(elCnt).Dimensions = 1;
eCAT(elCnt).DimensionsMode = 'Fixed';
eCAT(elCnt).DataType = 'int32';
eCAT(elCnt).SampleTime = -1;
eCAT(elCnt).Complexity = 'real';

elCnt = elCnt + 1;
eCAT(elCnt) = Simulink.BusElement;
eCAT(elCnt).Name = 'eCAT_NS_ClkDiff';
eCAT(elCnt).Dimensions = 1;
eCAT(elCnt).DimensionsMode = 'Fixed';
eCAT(elCnt).DataType = 'int32';
eCAT(elCnt).SampleTime = -1;
eCAT(elCnt).Complexity = 'real';
% =========================================================================

twin2CtrlBus = Simulink.Bus;
twin2CtrlBus.Elements = twin2ctrl;

ctrl2TwinBus = Simulink.Bus;
ctrl2TwinBus.Elements = ctrl2twin;

torqueBus = Simulink.Bus;
torqueBus.Elements = torque;

eCATBus = Simulink.Bus;
eCATBus.Elements = eCAT;

save(busFile,'eCATBus','twin2CtrlBus','ctrl2TwinBus','torqueBus')