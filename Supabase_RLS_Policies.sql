-- Unscroll Supabase RLS Policies
-- Row Level Security policies for all tables

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE skill_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE heart_state ENABLE ROW LEVEL SECURITY;
ALTER TABLE heart_refill_slots ENABLE ROW LEVEL SECURITY;
ALTER TABLE heart_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE badges ENABLE ROW LEVEL SECURITY;
ALTER TABLE badge_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress_tree_state ENABLE ROW LEVEL SECURITY;
ALTER TABLE progress_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_themes ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE wind_down_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE wind_down_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE deep_analytics ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_data_points ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_onboarding ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Users can view own profile" ON profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Game progress policies
CREATE POLICY "Users can view own game progress" ON game_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own game progress" ON game_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own game progress" ON game_progress
    FOR UPDATE USING (auth.uid() = user_id);

-- Skill progress policies
CREATE POLICY "Users can view own skill progress" ON skill_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own skill progress" ON skill_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own skill progress" ON skill_progress
    FOR UPDATE USING (auth.uid() = user_id);

-- Heart state policies
CREATE POLICY "Users can view own heart state" ON heart_state
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own heart state" ON heart_state
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own heart state" ON heart_state
    FOR UPDATE USING (auth.uid() = user_id);

-- Heart refill slots policies
CREATE POLICY "Users can view own heart refill slots" ON heart_refill_slots
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own heart refill slots" ON heart_refill_slots
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own heart refill slots" ON heart_refill_slots
    FOR UPDATE USING (auth.uid() = user_id);

-- Heart transactions policies
CREATE POLICY "Users can view own heart transactions" ON heart_transactions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own heart transactions" ON heart_transactions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Badges policies
CREATE POLICY "Users can view own badges" ON badges
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own badges" ON badges
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Badge progress policies
CREATE POLICY "Users can view own badge progress" ON badge_progress
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own badge progress" ON badge_progress
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own badge progress" ON badge_progress
    FOR UPDATE USING (auth.uid() = user_id);

-- Progress tree state policies
CREATE POLICY "Users can view own progress tree state" ON progress_tree_state
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own progress tree state" ON progress_tree_state
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own progress tree state" ON progress_tree_state
    FOR UPDATE USING (auth.uid() = user_id);

-- Progress nodes policies
CREATE POLICY "Users can view progress nodes" ON progress_nodes
    FOR SELECT USING (true);

-- User settings policies
CREATE POLICY "Users can view own user settings" ON user_settings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own user settings" ON user_settings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own user settings" ON user_settings
    FOR UPDATE USING (auth.uid() = user_id);

-- User themes policies
CREATE POLICY "Users can view own user themes" ON user_themes
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own user themes" ON user_themes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own user themes" ON user_themes
    FOR UPDATE USING (auth.uid() = user_id);

-- Challenge results policies
CREATE POLICY "Users can view own challenge results" ON challenge_results
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own challenge results" ON challenge_results
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Daily sessions policies
CREATE POLICY "Users can view own daily sessions" ON daily_sessions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own daily sessions" ON daily_sessions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own daily sessions" ON daily_sessions
    FOR UPDATE USING (auth.uid() = user_id);

-- User stats policies
CREATE POLICY "Users can view own user stats" ON user_stats
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own user stats" ON user_stats
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own user stats" ON user_stats
    FOR UPDATE USING (auth.uid() = user_id);

-- Training plans policies
CREATE POLICY "Users can view own training plans" ON training_plans
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own training plans" ON training_plans
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own training plans" ON training_plans
    FOR UPDATE USING (auth.uid() = user_id);

-- Training recommendations policies
CREATE POLICY "Users can view own training recommendations" ON training_recommendations
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own training recommendations" ON training_recommendations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own training recommendations" ON training_recommendations
    FOR UPDATE USING (auth.uid() = user_id);

-- Wind down sessions policies
CREATE POLICY "Users can view own wind down sessions" ON wind_down_sessions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own wind down sessions" ON wind_down_sessions
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Wind down settings policies
CREATE POLICY "Users can view own wind down settings" ON wind_down_settings
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own wind down settings" ON wind_down_settings
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own wind down settings" ON wind_down_settings
    FOR UPDATE USING (auth.uid() = user_id);

-- Deep analytics policies
CREATE POLICY "Users can view own deep analytics" ON deep_analytics
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own deep analytics" ON deep_analytics
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Analytics data points policies
CREATE POLICY "Users can view own analytics data points" ON analytics_data_points
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own analytics data points" ON analytics_data_points
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- User onboarding policies
CREATE POLICY "Users can view own user onboarding" ON user_onboarding
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own user onboarding" ON user_onboarding
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own user onboarding" ON user_onboarding
    FOR UPDATE USING (auth.uid() = user_id);
