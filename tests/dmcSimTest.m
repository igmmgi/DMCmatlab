classdef dmcSimTest < matlab.unittest.TestCase
  % Basic test of function dmcSim
  
  properties
    rt_tolerance  = 2;
    sd_tolerance  = 2;
    err_tolerance = 0.5;
  end
  
  methods (Test)
    
    % Simulation 1 (Figure 3)
    % amp = 20, tau = 30, mu = 0.5, sigm = 4, bnds = 75, resMean = 300, resSD = 30
    function test1(testCase)
      
      res = dmcSim('makePlots', false);
      
      testCase.assertLessThanOrEqual(abs(440 - res.summary.rtCorr(1)),   testCase.rt_tolerance)
      testCase.assertLessThanOrEqual(abs(106 - res.summary.sdRtCorr(1)), testCase.sd_tolerance)
      testCase.assertLessThanOrEqual(abs(0.7 - res.summary.perErr(1)),   testCase.err_tolerance)
      testCase.assertLessThanOrEqual(abs(458 - res.summary.rtCorr(2)),   testCase.rt_tolerance)
      testCase.assertLessThanOrEqual(abs(95  - res.summary.sdRtCorr(2)), testCase.sd_tolerance)
      testCase.assertLessThanOrEqual(abs(1.4 - res.summary.perErr(2)),   testCase.err_tolerance)
      
    end
    
    % Simulation 2 (Figure 4)
    % amp = 20, tau = 150, mu = 0.5, sigm = 4, bnds = 75, resMean = 300, resSD = 30
    function test2(testCase)
      
      res = dmcSim('tau', 150, 'makePlots', false);
      
      testCase.assertLessThanOrEqual(abs(422 - res.summary.rtCorr(1)),   testCase.rt_tolerance)
      testCase.assertLessThanOrEqual(abs(90  - res.summary.sdRtCorr(1)), testCase.sd_tolerance)
      testCase.assertLessThanOrEqual(abs(0.3 - res.summary.perErr(1)),   testCase.err_tolerance)
      testCase.assertLessThanOrEqual(abs(483 - res.summary.rtCorr(2)),   testCase.rt_tolerance)
      testCase.assertLessThanOrEqual(abs(103 - res.summary.sdRtCorr(2)), testCase.sd_tolerance)
      testCase.assertLessThanOrEqual(abs(2.2 - res.summary.perErr(2)),   testCase.err_tolerance)
      
    end
    
    % Simulation 3 (Figure 5)
    % amp = 20, tau = 90, mu = 0.5, sigm = 4, bnds = 75, resMean = 300, resSD = 30
    function test3(testCase)
      
      res = dmcSim('tau', 90, 'makePlots', false);
      
      testCase.assertLessThanOrEqual(abs(420 - res.summary.rtCorr(1)),   testCase.rt_tolerance)
      testCase.assertLessThanOrEqual(abs(96  - res.summary.sdRtCorr(1)), testCase.sd_tolerance)
      testCase.assertLessThanOrEqual(abs(0.3 - res.summary.perErr(1)),   testCase.err_tolerance)
      testCase.assertLessThanOrEqual(abs(477 - res.summary.rtCorr(2)),   testCase.rt_tolerance)
      testCase.assertLessThanOrEqual(abs(96  - res.summary.sdRtCorr(2)), testCase.sd_tolerance)
      testCase.assertLessThanOrEqual(abs(2.4 - res.summary.perErr(2)),   testCase.err_tolerance)
      
    end
    
    % Simulation 3 (Figure 6)
    % amp = 20, tau = 30, mu = 0.5, sigm = 4, bnds = 75, resMean = 300, resSD = 30
    function test4(testCase)
      
      res = dmcSim('varSP', true, 'makePlots', false);
      
      testCase.assertLessThanOrEqual(abs(436 - res.summary.rtCorr(1)),   testCase.rt_tolerance)
      testCase.assertLessThanOrEqual(abs(116 - res.summary.sdRtCorr(1)), testCase.sd_tolerance)
      testCase.assertLessThanOrEqual(abs(1.7 - res.summary.perErr(1)),   testCase.err_tolerance)
      testCase.assertLessThanOrEqual(abs(452 - res.summary.rtCorr(2)),   testCase.rt_tolerance)
      testCase.assertLessThanOrEqual(abs(101 - res.summary.sdRtCorr(2)), testCase.sd_tolerance)
      testCase.assertLessThanOrEqual(abs(6.9 - res.summary.perErr(2)),   testCase.err_tolerance)
      
    end
    
    % Simulation 3 (Figure 7)
    % amp = 20, tau = 30, mu = 0.5, sigm = 4, bnds = 75, resMean = 300, resSD = 30
    function test5(testCase)
      
      res = dmcSim( 'varDR', true, 'makePlots', false);
      
      testCase.assertLessThanOrEqual(abs(500  - res.summary.rtCorr(1)),   testCase.rt_tolerance)
      testCase.assertLessThanOrEqual(abs(175  - res.summary.sdRtCorr(1)), testCase.sd_tolerance)
      testCase.assertLessThanOrEqual(abs(12.1 - res.summary.perErr(1)),   testCase.err_tolerance)
      testCase.assertLessThanOrEqual(abs(522  - res.summary.rtCorr(2)),   testCase.rt_tolerance)
      testCase.assertLessThanOrEqual(abs(164  - res.summary.sdRtCorr(2)), testCase.sd_tolerance)
      testCase.assertLessThanOrEqual(abs(13.9 - res.summary.perErr(2)),   testCase.err_tolerance)
      
    end
    
  end
  
end
