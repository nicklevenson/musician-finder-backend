require "test_helper"

class ConnectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @connection = connections(:one)
  end

  test "should get index" do
    get connections_url, as: :json
    assert_response :success
  end

  test "should create connection" do
    assert_difference('Connection.count') do
      post connections_url, params: { connection: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show connection" do
    get connection_url(@connection), as: :json
    assert_response :success
  end

  test "should update connection" do
    patch connection_url(@connection), params: { connection: {  } }, as: :json
    assert_response 200
  end

  test "should destroy connection" do
    assert_difference('Connection.count', -1) do
      delete connection_url(@connection), as: :json
    end

    assert_response 204
  end
end
