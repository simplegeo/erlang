%%
%% %CopyrightBegin%
%%
%% Copyright Ericsson AB 2009-2010. All Rights Reserved.
%%
%% The contents of this file are subject to the Erlang Public License,
%% Version 1.1, (the "License"); you may not use this file except in
%% compliance with the License. You should have received a copy of the
%% Erlang Public License along with this software. If not, it can be
%% retrieved online at http://www.erlang.org/.
%%
%% Software distributed under the License is distributed on an "AS IS"
%% basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See
%% the License for the specific language governing rights and limitations
%% under the License.
%%
%% %CopyrightEnd%
%%

%%%-------------------------------------------------------------------
%%% File: ct_test_server_if_SUITE
%%%
%%% Description: 
%%% Test the test_server -> framework interface.
%%%
%%% The suites used for the test are located in the data directory.
%%%-------------------------------------------------------------------
-module(ct_test_server_if_1_SUITE).

-compile(export_all).

-include_lib("test_server/include/test_server.hrl").
-include_lib("common_test/include/ct_event.hrl").

-define(eh, ct_test_support_eh).

%%--------------------------------------------------------------------
%% TEST SERVER CALLBACK FUNCTIONS
%%--------------------------------------------------------------------

%%--------------------------------------------------------------------
%% Description: Since Common Test starts another Test Server
%% instance, the tests need to be performed on a separate node (or
%% there will be clashes with logging processes etc).
%%--------------------------------------------------------------------
init_per_suite(Config) ->
    Config1 = ct_test_support:init_per_suite(Config),
    Config1.

end_per_suite(Config) ->
    ct_test_support:end_per_suite(Config).

init_per_testcase(TestCase, Config) ->
    ct_test_support:init_per_testcase(TestCase, Config).

end_per_testcase(TestCase, Config) ->
    ct_test_support:end_per_testcase(TestCase, Config).

all(doc) -> 
    [""];

all(suite) -> 
    [
     ts_if_1
    ].
     

%%--------------------------------------------------------------------
%% TEST CASES
%%--------------------------------------------------------------------

%%%-----------------------------------------------------------------
%%% 
ts_if_1(Config) when is_list(Config) -> 
    DataDir = ?config(data_dir, Config),
    PrivDir = ?config(priv_dir, Config),
    TODir = filename:join(DataDir, "test_server_if"),
    Level = ?config(trace_level, Config),
    TestSpec = [
		{event_handler,?eh,[{cbm,ct_test_support},{trace_level,Level}]},
		{suites,TODir,[ts_if_1_SUITE,ts_if_2_SUITE,ts_if_3_SUITE,
			       ts_if_4_SUITE,ts_if_5_SUITE,ts_if_6_SUITE,
			       ts_if_7_SUITE,ts_if_8_SUITE]},
		{skip_suites,TODir,[skipped_by_spec_1_SUITE],"should be skipped"},
		{skip_cases,TODir,skipped_by_spec_2_SUITE,[tc1],"should be skipped"}
	       ],

    TestSpecName = ct_test_support:write_testspec(TestSpec, PrivDir, "ts_if_1_spec"),
    {Opts,ERPid} = setup({spec,TestSpecName}, Config),
    ok = ct_test_support:run(Opts, Config),
    Events = ct_test_support:get_events(ERPid, Config),

    ct_test_support:log_events(ts_if_1, 
			       reformat(Events, ?eh), 
			       PrivDir),

    TestEvents = events_to_check(ts_if_1),
    ok = ct_test_support:verify_events(TestEvents, Events, Config).
        

%%%-----------------------------------------------------------------
%%% HELP FUNCTIONS
%%%-----------------------------------------------------------------

setup(Test, Config) ->
    Opts0 = ct_test_support:get_opts(Config),
%    Level = ?config(trace_level, Config),
%    EvHArgs = [{cbm,ct_test_support},{trace_level,Level}],
%    Opts = Opts0 ++ [Test,{event_handler,{?eh,EvHArgs}}],
    Opts = [Test | Opts0],
    ERPid = ct_test_support:start_event_receiver(Config),
    {Opts,ERPid}.

reformat(Events, EH) ->
    ct_test_support:reformat(Events, EH).
%reformat(Events, _EH) ->
%    Events.

%%%-----------------------------------------------------------------
%%% TEST EVENTS
%%%-----------------------------------------------------------------
events_to_check(Test) ->
    %% 2 tests (ct:run_test + script_start) is default
    events_to_check(Test, 2).

events_to_check(_, 0) ->
    [];
events_to_check(Test, N) ->
    test_events(Test) ++ events_to_check(Test, N-1).

test_events(ts_if_1) ->
    [
     {?eh,start_logging,{'DEF','RUNDIR'}},
     {?eh,test_start,{'DEF',{'START_TIME','LOGDIR'}}},
     {?eh,start_info,{10,6,26}},
     {?eh,tc_start,{ts_if_1_SUITE,init_per_suite}},
     {?eh,tc_done,{ts_if_1_SUITE,init_per_suite,ok}},
     {?eh,tc_start,{ts_if_1_SUITE,tc1}},
     {?eh,tc_done,{ts_if_1_SUITE,tc1,{skipped,
				      {failed,
				       {ts_if_1_SUITE,init_per_testcase,
					{timetrap_timeout,2000}}}}}},
     {?eh,test_stats,{0,0,{0,1}}},
     {?eh,tc_start,{ts_if_1_SUITE,tc2}},
     {?eh,tc_done,{ts_if_1_SUITE,tc2,
		   {failed,{ts_if_1_SUITE,end_per_testcase,{timetrap_timeout,2000}}}}},
     {?eh,test_stats,{1,0,{0,1}}},
     {?eh,tc_start,{ts_if_1_SUITE,tc3}},
     {?eh,tc_done,{ts_if_1_SUITE,tc3,{failed,{timetrap_timeout,2000}}}},
     {?eh,test_stats,{1,1,{0,1}}},
     {?eh,tc_start,{ts_if_1_SUITE,tc4}},
     {?eh,tc_done,{ts_if_1_SUITE,tc4,{failed,{error,failed_on_purpose}}}},
     {?eh,test_stats,{1,2,{0,1}}},
     {?eh,tc_done,{ts_if_1_SUITE,tc5,{skipped,{sequence_failed,seq1,tc4}}}},
     {?eh,test_stats,{1,2,{1,1}}},

     [{?eh,tc_start,{ts_if_1_SUITE,{init_per_group,seq2,[sequence]}}},
      {?eh,tc_done,{ts_if_1_SUITE,{init_per_group,seq2,[sequence]},ok}},
      {?eh,tc_start,{ts_if_1_SUITE,tc4}},
      {?eh,tc_done,{ts_if_1_SUITE,tc4,{failed,{error,failed_on_purpose}}}},
      {?eh,test_stats,{1,3,{1,1}}},
      {?eh,tc_auto_skip,{ts_if_1_SUITE,tc5,{failed,{ts_if_1_SUITE,tc4}}}},
      {?eh,test_stats,{1,3,{1,2}}},
      {?eh,tc_start,{ts_if_1_SUITE,{end_per_group,seq2,[sequence]}}},
      {?eh,tc_done,{ts_if_1_SUITE,{end_per_group,seq2,[sequence]},ok}}],

     {?eh,tc_start,{ts_if_1_SUITE,tc6}},
     {?eh,tc_done,{ts_if_1_SUITE,tc6,{skipped,{require_failed,{not_available,void}}}}},
     {?eh,test_stats,{1,3,{1,3}}},
     {?eh,tc_start,{ts_if_1_SUITE,tc7}},
     {?eh,tc_done,{ts_if_1_SUITE,tc7,ok}},
     {?eh,test_stats,{2,3,{1,3}}},
     {?eh,tc_start,{ts_if_1_SUITE,tc8}},
     {?eh,tc_done,{ts_if_1_SUITE,tc8,{skipped,"tc8 skipped"}}},
     {?eh,test_stats,{2,3,{2,3}}},
     {?eh,tc_start,{ts_if_1_SUITE,tc9}},
     {?eh,tc_done,{ts_if_1_SUITE,tc9,{skipped,'tc9 skipped'}}},
     {?eh,test_stats,{2,3,{3,3}}},
     {?eh,tc_start,{ts_if_1_SUITE,tc10}},
     {?eh,tc_done,{ts_if_1_SUITE,tc10,{failed,{error,{function_clause,'_'}}}}},
     {?eh,test_stats,{2,4,{3,3}}},
     {?eh,tc_start,{ts_if_1_SUITE,tc11}},
     {?eh,tc_done,{ts_if_1_SUITE,tc11,
		   {skipped,{failed,{ts_if_1_SUITE,init_per_testcase,bad_return}}}}},
     {?eh,test_stats,{2,4,{3,4}}},

     [{?eh,tc_start,{ts_if_1_SUITE,{init_per_group,g1,[]}}},
      {?eh,tc_done,{ts_if_1_SUITE,{init_per_group,g1,[]},{skipped,g1_got_skipped}}},
      {?eh,tc_auto_skip,{ts_if_1_SUITE,gtc1,g1_got_skipped}},
      {?eh,test_stats,{2,4,{3,5}}},
      {?eh,tc_auto_skip,{ts_if_1_SUITE,end_per_group,g1_got_skipped}}],

     {parallel,
      [{?eh,tc_start,{ts_if_1_SUITE,{init_per_group,g2,[parallel]}}},
       {?eh,tc_done,{ts_if_1_SUITE,{init_per_group,g2,[parallel]},ok}},
       [{?eh,tc_start,{ts_if_1_SUITE,{init_per_group,g3,[]}}},
	{?eh,tc_done,{ts_if_1_SUITE,{init_per_group,g3,[]},{skipped,g3_got_skipped}}},
	{?eh,tc_auto_skip,{ts_if_1_SUITE,gtc2,g3_got_skipped}},
	{?eh,test_stats,{2,4,{3,6}}},
	{?eh,tc_auto_skip,{ts_if_1_SUITE,end_per_group,g3_got_skipped}}],
       {?eh,tc_start,{ts_if_1_SUITE,{end_per_group,g2,[parallel]}}},
       {?eh,tc_done,{ts_if_1_SUITE,{end_per_group,g2,[parallel]},ok}}]},

     {?eh,tc_start,{ts_if_1_SUITE,tc12}},
     {?eh,tc_done,{ts_if_1_SUITE,tc12,{failed,{testcase_aborted,'stopping tc12'}}}},
     {?eh,test_stats,{2,5,{3,6}}},
     {?eh,tc_start,{ts_if_1_SUITE,tc13}},
     {?eh,tc_done,{ts_if_1_SUITE,tc13,ok}},
     {?eh,test_stats,{3,5,{3,6}}},
     {?eh,tc_start,{ts_if_1_SUITE,end_per_suite}},
     {?eh,tc_done,{ts_if_1_SUITE,end_per_suite,ok}},

     {?eh,tc_start,{ts_if_2_SUITE,init_per_suite}},
     {?eh,tc_done,{ts_if_2_SUITE,init_per_suite,
		   {failed,{error,{suite0_failed,{exited,suite0_goes_boom}}}}}},
     {?eh,tc_auto_skip,{ts_if_2_SUITE,my_test_case,
			{failed,{error,{suite0_failed,{exited,suite0_goes_boom}}}}}},
     {?eh,test_stats,{3,5,{3,7}}},
     {?eh,tc_auto_skip,{ts_if_2_SUITE,end_per_suite,
			{failed,{error,{suite0_failed,{exited,suite0_goes_boom}}}}}},

     {?eh,tc_start,{ct_framework,error_in_suite}},
     {?eh,test_stats,{3,6,{3,7}}},

     {?eh,tc_start,{ct_framework,error_in_suite}},
     {?eh,test_stats,{3,7,{3,7}}},

     {?eh,tc_start,{ts_if_5_SUITE,init_per_suite}},
     {?eh,tc_done,{ts_if_5_SUITE,init_per_suite,
		   {skipped,{require_failed_in_suite0,{not_available,undef_variable}}}}},
     {?eh,tc_auto_skip,{ts_if_5_SUITE,my_test_case,
			{require_failed_in_suite0,{not_available,undef_variable}}}},
     {?eh,test_stats,{3,7,{3,8}}},
     {?eh,tc_auto_skip,{ts_if_5_SUITE,end_per_suite,
			{require_failed_in_suite0,{not_available,undef_variable}}}},

     {?eh,tc_start,{ts_if_6_SUITE,tc1}},
     {?eh,tc_done,{ts_if_6_SUITE,tc1,{failed,{error,{suite0_failed,{exited,suite0_byebye}}}}}},
     {?eh,test_stats,{3,7,{4,8}}},

     {?eh,tc_start,{ts_if_7_SUITE,tc1}},
     {?eh,tc_done,{ts_if_7_SUITE,tc1,ok}},
     {?eh,test_stats,{4,7,{4,8}}},

     {?eh,tc_start,{ts_if_8_SUITE,tc1}},
     {?eh,tc_done,{ts_if_8_SUITE,tc1,{failed,{error,failed_on_purpose}}}},
     {?eh,test_stats,{4,8,{4,8}}},

     {?eh,tc_user_skip,{skipped_by_spec_1_SUITE,all,"should be skipped"}},
     {?eh,test_stats,{4,8,{5,8}}},

     {?eh,tc_start,{skipped_by_spec_2_SUITE,init_per_suite}},
     {?eh,tc_done,{skipped_by_spec_2_SUITE,init_per_suite,ok}},
     {?eh,tc_user_skip,{skipped_by_spec_2_SUITE,tc1,"should be skipped"}},
     {?eh,test_stats,{4,8,{6,8}}},
     {?eh,tc_start,{skipped_by_spec_2_SUITE,end_per_suite}},
     {?eh,tc_done,{skipped_by_spec_2_SUITE,end_per_suite,ok}},

     {?eh,test_done,{'DEF','STOP_TIME'}},
     {?eh,stop_logging,[]}
    ].

